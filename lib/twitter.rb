require 'httparty'
require 'oauth'

class Twitter
  include HTTParty
  base_uri 'http://api.twitter.com'
  
  CONSUMER_KEY = 'j1TSYm9UPjbAt5d3xGPkVA'
  SECRET_KEY = '8kQ2eFNMKAAtb7TVD1orjOo2fATSlfcsYDRMmpCQEs'
  
  def self.oauth_consumer
    OAuth::Consumer.new(CONSUMER_KEY, SECRET_KEY, {:site => "http://api.twitter.com"})
  end
end