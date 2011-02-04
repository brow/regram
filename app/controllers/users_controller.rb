require 'instagram'

class UsersController < ApplicationController  
    
  def index  
    if session['user_id'] and @user = User.find_by_id(session['user_id'])
     # nothing
    else
      redirect_to :action => 'login'
      return
    end
    
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
      (user, access_token) = Instagram.get_user_and_access_token(params['code'])
      user = User.find_or_create_by_instagram_id(user['id'])
      user.instagram_access_token = access_token
      user.save()
      
      session['user_id'] = user.id
      redirect_to :action => 'index'
    end
  end
  
end
