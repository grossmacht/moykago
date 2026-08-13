class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  around_action :switch_locale

  helper_method :current_user, :current_customer

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_customer
    @current_customer ||= Customer.find_by(id: session[:customer_id]) if session[:customer_id]
  end

  private

  # Puma oqimlari so'rovlar orasida qayta ishlatiladi, shuning uchun oddiy
  # `I18n.locale = x` xavfli — `with_locale` har bir so'rovni izolyatsiya qiladi.
  # Xodimlar paneli (panel/admin) — faqat o'zbekcha, mijoz sessiyasidagi
  # til tanlovidan qat'i nazar.
  def switch_locale(&action)
    if params[:locale].present? && I18n.available_locales.map(&:to_s).include?(params[:locale])
      session[:locale] = params[:locale]
    end
    staff_area = params[:controller].to_s.start_with?("admin/", "panel/")
    locale = staff_area ? :uz : (session[:locale] || I18n.default_locale)
    I18n.with_locale(locale, &action)
  end

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

  def require_customer
    unless current_customer
      redirect_to customer_login_path, alert: "Avval tizimga kiring"
    end
  end
end
