class LoginController < ApplicationController  
  
  def index
    session['user_id'] = nil
    respond_to do |format|
      format.html
    end
  end
  
  def authorize 
    redirect_to Instagram.authorization_url
  end
  
  def callback  
    if (params['error'] || !params['code'])
      render :text => "Problem?"
    else
      (instagram_user, access_token) = Instagram.get_user_and_access_token(params['code'])
      user = User.find_or_create_by_instagram_id(instagram_user['id'])
      user.instagram_access_token = access_token
      user.save
      
      session['user_id'] = user.id
      redirect_to :controller => 'settings'
    end
  end
  
end
