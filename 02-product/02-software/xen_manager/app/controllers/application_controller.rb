class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :require_authentication
  before_action :refresh_session_timeout

  helper_method :current_user

  SESSION_TIMEOUT = 60.minutes

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_authentication
    unless current_user && session_active?
      reset_session
      redirect_to login_path
    end
  end

  def refresh_session_timeout
    session[:last_active_at] = Time.current.to_i
  end

  def session_active?
    last_active = session[:last_active_at]
    last_active && (Time.current.to_i - last_active) < SESSION_TIMEOUT
  end
end
