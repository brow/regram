require 'twitter'

class TwitterController < ApplicationController  
  
  before_filter :login_required
    
  def authorize
    request_token = Twitter.oauth_consumer.get_request_token(:oauth_callback => url_for(:action => 'callback'))
    session['twitter_request_token'] = request_token
    redirect_to request_token.authorize_url
  end
  
  def logout
    @user.twitter_access_token = nil
    @user.twitter_access_token_secret = nil
    @user.twitter_name = nil
    @user.save
    redirect_to :controller => 'settings'
  end
  
  def callback
    verifier = params['oauth_verifier']
    request_token = session['twitter_request_token']
    if request_token and verifier
      begin
        access_token = request_token.get_access_token(:oauth_verifier => verifier)
        @user.twitter_access_token = access_token.token
        @user.twitter_access_token_secret = access_token.secret
        @user.twitter_name = @user.twitter_screen_name
        @user.save
      rescue OAuth::Error => e
        #TODO: flash error message
      end
    else
      #TODO: flash error message
    end
    redirect_to :controller => 'settings'
  end
  
end