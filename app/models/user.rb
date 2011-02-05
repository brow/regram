require 'tumblr'

class User < ActiveRecord::Base
  def tumblr
    return nil unless tumblr_access_token and tumblr_access_token_secret
    OAuth::AccessToken.new(Tumblr.oauth_consumer, 
                          tumblr_access_token, 
                          tumblr_access_token_secret)
  end
  
  def tumblr_blog_names
    unless @tumblr_blog_names
      xml = tumblr.get('/api/authenticate').body
      blogs = Hpricot(xml)/"tumblelog"
      @tumblr_blog_names = blogs.map{|blog| blog['name']}.select{|name| name}
    end
    @tumblr_blog_names
  end
end