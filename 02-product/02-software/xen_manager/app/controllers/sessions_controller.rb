class SessionsController < ApplicationController
  skip_before_action :require_authentication
  skip_before_action :refresh_session_timeout

  def new
    redirect_to root_path if session[:user_id]
  end

  def create
    user = User.find_by(username: params[:username])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      session[:last_active_at] = Time.current.to_i
      redirect_to root_path
    else
      @error = "login failed"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path
  end
end
