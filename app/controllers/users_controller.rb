require 'instagram'
require 'tumblr'

class UsersController < ApplicationController  
  
  before_filter :login_required, :except => [:login, :oauth]
  
  def index
    respond_to do |format|
      format.html
    end
  end
  
  def login
    @authorization_url = Instagram.authorization_url
    respond_to do |format|
      format.html
    end
  end
  
  def logout
    session['user_id'] = nil
    redirect_to :action => 'index'
  end
  
  def oauth  
    if (params['error'] || !params['code'])
      render :text => "Problem?"
    else
      (instagram_user, access_token) = Instagram.get_user_and_access_token(params['code'])
      user = User.find_or_create_by_instagram_id(instagram_user['id'])
      user.instagram_access_token = access_token
      user.save
      
      session['user_id'] = user.id
      redirect_to :action => 'index'
    end
  end
  
  # Tumblr
  
  def login_tumblr
    request_token = Tumblr.oauth_consumer.get_request_token
    session['tumblr_request_token'] = request_token
    redirect_to request_token.authorize_url
  end
  
  def oauth_tumblr
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
      redirect_to :action => 'index'
    else
      render :text => "No request token"
    end
  end
  
end
