require 'httparty'
require 'oauth'

class Twitter
  include HTTParty
  base_uri 'http://api.twitter.com'
  
  CONSUMER_KEY = APP_CONFIG['twitter_consumer_key']
  SECRET_KEY = APP_CONFIG['twitter_consumer_secret']
  
  def self.oauth_consumer
    OAuth::Consumer.new(CONSUMER_KEY, SECRET_KEY, {:site => "http://api.twitter.com"})
  end
end