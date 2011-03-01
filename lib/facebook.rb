require 'httparty'

class Facebook
  include HTTParty
  base_uri 'https://graph.facebook.com'
  
  CLIENT_ID = APP_CONFIG['facebook_client_id']
  CLIENT_SECRET = APP_CONFIG['facebook_client_secret']
  CALLBACK_URI = APP_CONFIG['facebook_callback_uri']

  def self.authorization_url
    "https://www.facebook.com/dialog/oauth" +
       "?client_id=#{CLIENT_ID}" +
       "&redirect_uri=#{CALLBACK_URI}" +
       "&scope=publish_stream,offline_access" +
       "&display=touch"
  end

  def self.get_access_token(code)
    response = self.post('/oauth/access_token', :body => {
      :client_id => CLIENT_ID,
      :client_secret => CLIENT_SECRET,
      :redirect_uri => CALLBACK_URI,
      :code => code
    })
    return response.body.match('access_token=(.*)')[1]
  end
end