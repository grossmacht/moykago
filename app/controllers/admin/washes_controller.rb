module Admin
  class WashesController < ApplicationController
    before_action :require_admin
    before_action :set_wash, only: [ :edit, :update, :destroy ]

    def index
      @washes = Wash.includes(:users, :bookings).order(:name)
    end

    def new
      @wash = Wash.new
    end

    def create
      @wash = Wash.new(wash_params)
      if @wash.save
        create_owner_if_given
        redirect_to admin_washes_path, notice: "Moyka qo'shildi"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @wash.update(wash_params)
        create_owner_if_given
        redirect_to admin_washes_path, notice: "Moyka yangilandi"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @wash.destroy
      redirect_to admin_washes_path, notice: "Moyka o'chirildi"
    end

    private

    def set_wash
      @wash = Wash.find_by!(slug: params[:id])
    end

    def wash_params
      params.require(:wash).permit(
        :name, :district, :address, :phone, :description, :wash_type,
        :open_hour, :close_hour, :bays, :featured, :commission_rate, :latitude, :longitude
      )
    end

    def create_owner_if_given
      phone = params.dig(:owner, :phone).presence
      password = params.dig(:owner, :password).presence
      return unless phone && password
      user = User.find_or_initialize_by(phone: phone.gsub(/[^\d+]/, ""))
      user.name ||= "#{@wash.name} egasi"
      user.name = "#{@wash.name} egasi" if user.new_record?
      user.wash = @wash
      user.password = password
      user.role ||= :owner
      unless user.save
        flash[:alert] = "Moyka saqlandi, lekin egasi yaratilmadi: #{user.errors.full_messages.to_sentence}"
      end
    end
  end
end
