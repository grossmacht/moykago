module Panel
  class SessionsController < ApplicationController
    def new
      redirect_to_panel if current_user
    end

    def create
      user = User.find_by(phone: params[:phone].to_s.gsub(/[^\d+]/, ""))
      if user&.authenticate(params[:password])
        session[:user_id] = user.id
        redirect_to_panel
      else
        flash.now[:alert] = "Telefon raqam yoki parol noto'g'ri"
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:user_id)
      redirect_to root_path, notice: "Tizimdan chiqdingiz"
    end

    private

    def redirect_to_panel
      if current_user.admin?
        redirect_to admin_root_path
      else
        redirect_to panel_bookings_path
      end
    end
  end
end
