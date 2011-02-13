require 'tumblr'

class TumblrController < ApplicationController 
  
  before_filter :login_required
  
  def index
    respond_to do |format|
      format.html
    end
  end
  
  def update
    @user.update_attributes(params['user'])
    redirect_to :controller => 'settings'
  end
  
  def authorize
    request_token = Tumblr.oauth_consumer.get_request_token
    session['tumblr_request_token'] = request_token
    redirect_to request_token.authorize_url
  end
  
  def logout
    @user.tumblr_access_token = nil
    @user.tumblr_access_token_secret = nil
    @user.tumblr_blog_name = nil
    @user.save
    redirect_to :controller => 'settings'
  end
  
  def callback
    verifier = params['oauth_verifier']
    request_token = session['tumblr_request_token']
    if request_token and verifier
      begin
        access_token = request_token.get_access_token(:oauth_verifier => verifier)
        @user.tumblr_access_token = access_token.token
        @user.tumblr_access_token_secret = access_token.secret
        @user.tumblr_blog_name = @user.tumblr_blog_names[0]
        @user.save
      rescue OAuth::Error => e
        # populate error flash?
      end
      redirect_to :controller => 'settings'
    else
      render :text => "No request token"
    end
  end
  
end