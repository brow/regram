require 'tumblr'

class TumblrController < ApplicationController 
  
  before_filter :login_required
  
  def index
    respond_to do |format|
      format.html
    end
  end
  
  def update
    tumblr_blog = @user.tumblr_blogs.find do |blog|
      blog[:name] == params['user']['tumblr_blog_name']
    end
    @user.tumblr_blog_name = tumblr_blog[:name]
    @user.tumblr_blog_title = tumblr_blog[:title]
    @user.save
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
    @user.tumblr_blog_title = nil
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
        
        tumblr_blog = @user.tumblr_blogs[0]
        @user.tumblr_blog_name = tumblr_blog[:name]
        @user.tumblr_blog_title = tumblr_blog[:title]
        
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