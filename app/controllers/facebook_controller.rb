require 'facebook'

class FacebookController < ApplicationController 
  
  before_filter :login_required
  
  def authorize
    redirect_to Facebook.authorization_url
  end
  
  def logout
    @user.facebook_access_token = nil
    @user.facebook_name = nil
    @user.save
    redirect_to :controller => 'settings'
  end
  
  def callback
    if (params['error'] || !params['code'])
      #TODO: flash error message
    else
      access_token = Facebook.get_access_token(params['code'])      
      @user.facebook_access_token = access_token
      @user.facebook_name = @user.facebook_full_name
      @user.save    
    end
    redirect_to :controller => 'settings'
  end
  
end