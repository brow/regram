require 'instagram'
require 'tumblr'
require 'twitter'

class UsersController < ApplicationController  
  
  before_filter :login_required, :except => [:login, :authorize, :oauth]
  
  def index
    respond_to do |format|
      format.html
    end
  end
  
  def login
    respond_to do |format|
      format.html
    end
  end
  
  def authorize 
    redirect_to Instagram.authorization_url
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
  
  def logout_tumblr
    @user.tumblr_access_token = nil
    @user.tumblr_access_token_secret = nil
    @user.tumblr_blog_name = nil
    @user.save
    redirect_to :action => 'index'
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
  
  # Twitter
  
  def login_twitter
    request_token = Twitter.oauth_consumer.get_request_token(:oauth_callback => url_for(:action => 'oauth_twitter'))
    session['twitter_request_token'] = request_token
    redirect_to request_token.authorize_url
  end
  
  def logout_twitter
    @user.twitter_access_token = nil
    @user.twitter_access_token_secret = nil
    @user.twitter_name = nil
    @user.save
    redirect_to :action => 'index'
  end
  
  def oauth_twitter
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
        # populate error flash?
      end
      redirect_to :action => 'index'
    else
      render :text => "No request token"
    end
  end
  
end
