require 'rubygems'
require 'httparty'

class HTTParty::Response
  def fail!
    raise self['message'] if self['status'] == 'fail'
  end
end

class InstagramPrivate
  include HTTParty
  base_uri "instagr.am/api/v1"
  
  attr_reader :cookies
  
  def initialize( username='regram', 
                  password='cr4zycr4zy', 
                  udid='169ac49621beca9eb1593c0babdd123267b30319',
                  cookies=[])
    @username = username
    @password = password
    @udid = udid
    @cookies = cookies
  end
  
  def headers
    {
      'User-Agent' => 'Instagram 1.12.1 (iPhone; iPhone OS 4.1; en_US)', 
      'Cookie' => @cookies.join('; ')
    }
  end
  
  def login
    res = self.class.post("/accounts/login/", :body => {
      :username => @username,
      :password => @password,
      :device_id => @udid
    })
    @cookies = res.headers.to_hash['set-cookie'].map{|c| c.split(';')[0]}
    res
  end 
  
  def current_user
    self.class.get("/friendships/current_user/", :headers => headers)
  end
  
  def stats
    self.class.get("/friendships/stats", :headers => headers)
  end
  
  def following(user_id)
    self.class.get("/friendships/#{user_id}/following", :headers => headers)
  end
  
  def followers(user_id)
    self.class.get("/friendships/#{user_id}/followers", :headers => headers)
  end
  
  def follow(user_id)
    self.class.get("/friendships/create/#{user_id}/", :headers => headers)
  end
  
  def unfollow(user_id)
    self.class.get("/friendships/destroy/#{user_id}/", :headers => headers)
  end
  
  def show_many
    self.class.post("/friendships/show_many/", 
      :headers => headers,
      :body => "user_id=530515"
    )
  end
  
  def show(user_id)
    self.class.get("/friendships/show/#{user_id}/", :headers => headers)
  end
  
  def timeline(user_id)
    self.class.get("/feed/user/#{user_id}/", :headers => headers)
  end
  
  def like(media_id)
    self.class.get("/media/#{media_id}/like/", :headers => headers)
  end
  
  def activity
    self.class.get("/activity/recent/", :headers => headers)
  end
  
  def permalink(media_id)
    self.class.get("/media/#{media_id}/permalink/", :headers => headers)
  end
end