require 'httparty'

class Instagram
  include HTTParty
  base_uri 'https://api.instagram.com'
  
  CLIENT_ID = APP_CONFIG['instagram_client_id']
  CLIENT_SECRET = APP_CONFIG['instagram_client_secret']
  CALLBACK_URI = APP_CONFIG['instagram_callback_uri']

  def self.authorization_url
    "https://api.instagram.com/oauth/authorize/" +
       "?client_id=#{CLIENT_ID}" +
       "&redirect_uri=#{CALLBACK_URI}" +
       "&response_type=code"
  end

  def self.get_user_and_access_token(code)
    response = self.post('/oauth/access_token', :body => {
      :client_id => CLIENT_ID,
      :client_secret => CLIENT_SECRET,
      :redirect_uri => CALLBACK_URI,
      :grant_type => 'authorization_code',
      :code => code
    })
    return [response['user'], response['access_token']]
  end
  
  def self.media(media_id)
    self.get("/v1/media/#{media_id}?client_id=#{CLIENT_ID}")
  end
end