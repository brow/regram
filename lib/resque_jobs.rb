require 'instagram_private'
require 'instagram'
require 'redis'
require 'facebook'

USERNAME = 'regram'
PASSWORD = 'cr4zycr4zy'
UDID = '169ac49621beca9eb1593c0babdd123267b30319'

class Job
  @@log = Logger.new("#{::Rails.root.to_s}/log/instagram.log")
  @@log.level = Logger::INFO
  @@log.formatter = proc do |severity, datetime, progname, msg|
    date_string = datetime.strftime('%Y-%m-%d %H:%M:%S')
    "#{date_string}: #{msg}\n"
  end
end

class ReadCommentsJob < Job
  @queue = :high
  
  LAST_CREATED_AT_KEY = 'regram:last_created_at'
  LAST_USER_IDS_KEY = 'regram:last_user_ids'
  
  def self.perform      
    redis = Redis.new
    
    # Request comment activity from Instagram's private API
    cookies = JSON.parse(redis.get('regram:instagram_cookies'))    
    response = InstagramPrivate.new(USERNAME, PASSWORD, UDID, cookies).activity
    response.fail!
    return unless items = response['items']
    
    # Filter out comments we've already seen
    if items.empty?
      new_comments = []
    else
      comments = items[0]['updates'].select{|u| u['content_type'] == 'comment'}
      if last_created_at = redis.get(LAST_CREATED_AT_KEY)
        last_user_ids = Set.new(JSON.parse(redis.get(LAST_USER_IDS_KEY) || "[]"))
        new_comments = comments.select do |comment|
          comment['created_at'] > last_created_at.to_i ||
          (comment['created_at'] == last_created_at.to_i && !last_user_ids.include?(comment['user']['pk']))
        end
      else
        new_comments = []
      end
    end
    
    @@log.info("#{new_comments.length} new comments")
        
    # Record which new comments we saw this time
    unless comments.empty?
      last_created_at = comments.map{|c| c['created_at']}.max
      last_user_ids = comments.select{|c| c['created_at'] == last_created_at}.map{|c| c['user']['pk']}
      redis.set(LAST_CREATED_AT_KEY, last_created_at)
      redis.set(LAST_USER_IDS_KEY, last_user_ids.to_json)
    end
    
    # Process new comments
    for comment in new_comments
      Resque.enqueue(ProcessCommentJob, comment)
    end
  end
end

class ProcessCommentJob < Job
  @queue = :medium
  
  def self.perform(update)
    # Parse relevant fields
    instagram_user_id = update['user']['pk']
    caption = (match = update['text'].match('@regram (.*)')) ? match[1] : ''
    via_name = update['media']['user']['username']
    media_id = update['media']['pk']
    media_img_url = update['media']['image_versions'].sort_by{|v| -v['width']}[0]['url']
    
    # See if we actually need to do anything with this comment
    return unless user = User.find_by_instagram_id(instagram_user_id)
    return unless user.tumblr? or user.twitter? or user.facebook?
    
    # Get permalink
    response = Instagram.media(media_id)
    response.fail!
    permalink = response['data']['link']
    
    Resque.enqueue(WriteTumblrJob, user.id, media_img_url, caption, via_name, permalink) if user.tumblr?
    Resque.enqueue(WriteTwitterJob, user.id, media_img_url, caption, via_name, permalink) if user.twitter?
    Resque.enqueue(WriteFacebookJob, user.id, media_img_url, caption, via_name, permalink) if user.facebook?
  end
end

class WriteTumblrJob < Job
  @queue = :low
  
  def self.perform(user_id, image_url, caption, via_name, permalink)
    return unless user = User.find_by_id(user_id)
    media_link = permalink || image_url
    text = "#{caption} (via <a href='#{media_link}'>#{via_name}</a>)"
    user.tumblr.post('/api/write', {
      :type => 'photo',
      :source => image_url,
      :caption => text,
      'click-through-url' => media_link,
      :generator => 'regram',
      :group => user.tumblr_blog_name
    }).value
    @@log.info("posted to #{user.tumblr_blog_name}")
  end
end

class WriteTwitterJob < Job
  @queue = :low
  
  def self.perform(user_id, image_url, caption, via_name, permalink)
    return unless user = User.find_by_id(user_id)
    media_link = permalink || image_url
    if caption.empty?
      status = media_link
    else
      text_helper = Object.new.extend(ActionView::Helpers::TextHelper)
      truncated_caption = text_helper.truncate(caption, {
        :length => 140 - (media_link.length + 1), 
        :omission => '…',
        :separator => ' '
      })
      status = "#{truncated_caption} #{media_link}"
    end
    user.twitter.post('/1/statuses/update.xml', {
      :status => status
    }).value
    @@log.info("posted to @#{user.twitter_name}")
  end
end

class WriteFacebookJob < Job
  @queue = :low
  
  def self.perform(user_id, image_url, caption, via_name, permalink)
    return unless user = User.find_by_id(user_id)
    media_link = permalink || image_url

    Facebook.post('/me/feed', :body => {
      :access_token => user.facebook_access_token,
      :message => caption,
      :link => media_link,
      :picture => image_url,
      :name => "#{via_name}'s photo"
    }).value
    @@log.info("posted to #{user.facebook_name}")
  end
end

class ScheduleMinuteJob
  @queue = :high
  
  def self.perform
    # This job is run each minute and can enqueue multiple delayed jobs to get
    # around the one-minute frequency limit of cron and resque_scheduler
    (10..60).step(10) do |n|
      Resque.enqueue_in(n.seconds, ReadCommentsJob)
    end
  end
end

class UpdateCookiesJob < Job
  @queue = :medium
  
  def self.perform
    redis = Redis.new
    
    @@api = InstagramPrivate.new(USERNAME, PASSWORD, UDID)
    @@api.login.fail!
    
    if (@@api.cookies)
      redis.set('regram:instagram_cookies', @@api.cookies.to_json)
      @@log.info("got cookies with #{@@api.cookies[0]}")
    else
      raise 'No cookies retrieved.'
    end
  end
end