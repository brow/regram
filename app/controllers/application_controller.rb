class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def login_required
    unless session['user_id'] and @user = User.find_by_id(session['user_id'])
      redirect_to :action => 'login'
    end
  end
end
