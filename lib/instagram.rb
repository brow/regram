require 'httparty'

class Instagram
  include HTTParty
  base_uri 'http://api-privatebeta.instagr.am'
  
  CLIENT_ID = '1ced2a0708aa48b1ba01c882e4f627aa'
  CLIENT_SECRET = 'f5c73f993917481796ab089a3b8212dd'
  REDIRECT_URI = 'http://localhost:3000/users/oauth'

  def self.authorization_url
    "http://api-privatebeta.instagr.am/oauth/authorize/?client_id=#{CLIENT_ID}&redirect_uri=#{REDIRECT_URI}&response_type=code"
  end

  def self.get_user_and_access_token(code)
    response = self.post('/oauth/access_token', :body => {
      :client_id => CLIENT_ID,
      :client_secret => CLIENT_SECRET,
      :redirect_uri => REDIRECT_URI,
      :grant_type => 'authorization_code',
      :code => code
    })
    return [response['user'], response['access_token']]
  end
end