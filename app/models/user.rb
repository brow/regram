require 'tumblr'
require 'twitter'

class User < ActiveRecord::Base
  # Tumblr
  
  def tumblr?
    tumblr_access_token and tumblr_access_token_secret
  end
  
  def tumblr
    return nil unless tumblr?
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
  
  # Twitter
  
  def twitter?
    twitter_access_token and twitter_access_token_secret
  end
  
  def twitter
    return nil unless twitter?
    OAuth::AccessToken.new(Twitter.oauth_consumer, 
                          twitter_access_token, 
                          twitter_access_token_secret)
  end
  
  def twitter_screen_name
    unless @twitter_screen_name
      xml = twitter.get('/1/account/verify_credentials.xml').body
      @twitter_screen_name = (Hpricot(xml)/"screen_name").inner_text
    end
    @twitter_screen_name
  end
  
  # Facebook
  
  def facebook?
    facebook_access_token
  end
  
  def facebook_full_name
    unless @facebook_full_name
      response = Facebook.get('/me', :query => {:access_token => facebook_access_token})
      @facebook_full_name = response['name']
    end
    return @facebook_full_name
  end
end