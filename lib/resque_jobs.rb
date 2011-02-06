require 'instagram_private'
require 'resque'

USERNAME = 'regram'
PASSWORD = 'cra4zycr4zy'
UDID = '169ac49621beca9eb1593c0babdd123267b30319'
COOKIES = [ "sessionid=972b30d80389397a46386e011e51e33e", 
            "ds_user=regram", 
            "ds_user_id=1248004"]

class InstagramAPIJob
  @@api = Instagram.new(USERNAME, PASSWORD, UDID, COOKIES)
end

class ReadCommentsJob < InstagramAPIJob
  @queue = :instagram
  def self.perform
    response = @@api.activity
    response.fail!
    return unless items = response['items']
    
    #TODO: ignore duplicate updates
    
    for update in items[0]['updates'].select{|u| u['content_type'] == 'comment'}
      Resque.enqueue(ProcessCommentJob, update)
    end
  end
end

class ProcessCommentJob < InstagramAPIJob
  @queue = :instagram
  
  def self.perform(update)
    # Parse relevant fields
    instagram_user_id = update['user']['pk']
    caption = (match = update['text'].match('@regram (.*)')) ? match[1] : nil
    via_name = update['media']['user']['username']
    media_id = update['media']['pk']
    media_img_url = update['media']['image_versions'].sort_by{|v| -v['width']}[0]['url']
    
    # See if we actually need to do anything with this comment
    return unless user = User.find_by_instagram_id(instagram_user_id)
    return unless user.tumblr? or user.twitter?
    
    # Get permalink
    response = @@api.permalink(media_id)
    response.fail!
    permalink = response['permalink']
    
    Resque.enqueue(WriteTumblrJob, user.id, media_img_url, caption, via_name, permalink) if user.tumblr?
    Resque.enqueue(WriteTwitterJob, user.id, caption, via_name, permalink) if user.twitter?
  end
end

class WriteTumblrJob 
  @queue = :tumblr
  def self.perform(user_id, image_url, caption, via_name, permalink)
    return unless user = User.find_by_id(user_id)
    text = "#{caption} (via <a href='#{permalink}'>#{via_name}</a>)"
    user.tumblr.post('/api/write', {
      :type => 'photo',
      :source => image_url,
      :caption => text,
      'click-through-url' => permalink,
      :generator => 'regram',
      :group => user.tumblr_blog_name + '.tumblr.com'
    }).value
  end
end

class WriteTwitterJob 
  @queue = :twitter
  def self.perform(user_id, caption, via_name, permalink)
    return unless user = User.find_by_id(user_id)
    text_helper = Object.new.extend(ActionView::Helpers::TextHelper)
    attr_and_link = " #{permalink}"
    truncated_caption = text_helper.truncate(caption, {
      :length => 140 - attr_and_link.length, 
      :omission => '…',
      :separator => ' '
    })
    user.twitter.post('/1/statuses/update.xml', {
      :status => truncated_caption + attr_and_link
    }).value
  end
end