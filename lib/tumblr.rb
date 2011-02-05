require 'httparty'
require 'oauth'

class Tumblr
  include HTTParty
  base_uri 'http://api-privatebeta.instagr.am'
  
  CONSUMER_KEY = 'RqzEQ6OKxWEQcRjeC9KxWJ6HjQTI1WxoayHyOJ2JxWiXy4yXhQ'
  SECRET_KEY = 'tiEgII1RYiWgLsCU9TJdcTw8oKcd42iWhcdaUXgCIrRZ8pZAMG'
  
  def self.oauth_consumer
    OAuth::Consumer.new(CONSUMER_KEY, SECRET_KEY, {:site => "http://tumblr.com"})
  end
end