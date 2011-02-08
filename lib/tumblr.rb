require 'httparty'
require 'oauth'

class Tumblr
  include HTTParty
  base_uri 'http://www.tumblr.com'
  
  CONSUMER_KEY = APP_CONFIG['tumblr_consumer_key']
  SECRET_KEY = APP_CONFIG['tumblr_consumer_secret']
  
  def self.oauth_consumer
    OAuth::Consumer.new(CONSUMER_KEY, SECRET_KEY, {:site => "http://www.tumblr.com"})
  end
end