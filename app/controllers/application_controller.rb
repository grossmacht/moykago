class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  private

  def require_owner
    unless current_user
      redirect_to panel_login_path, alert: "Avval tizimga kiring"
    end
  end

  def require_admin
    unless current_user&.admin?
      redirect_to panel_login_path, alert: "Bu bo'lim faqat administrator uchun"
    end
  end
end
