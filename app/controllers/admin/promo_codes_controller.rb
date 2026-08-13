module Admin
  class PromoCodesController < ApplicationController
    before_action :require_admin
    before_action :set_promo_code, only: [ :edit, :update, :destroy ]

    def index
      @promo_codes = PromoCode.order(created_at: :desc)
    end

    def new
      @promo_code = PromoCode.new
    end

    def create
      @promo_code = PromoCode.new(promo_code_params)
      if @promo_code.save
        redirect_to admin_promo_codes_path, notice: "Promo-kod qo'shildi"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @promo_code.update(promo_code_params)
        redirect_to admin_promo_codes_path, notice: "Promo-kod yangilandi"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @promo_code.destroy
      redirect_to admin_promo_codes_path, notice: "Promo-kod o'chirildi"
    end

    private

    def set_promo_code
      @promo_code = PromoCode.find(params[:id])
    end

    def promo_code_params
      params.require(:promo_code).permit(
        :code, :discount_type, :value, :expires_at, :usage_limit, :min_amount
      )
    end
  end
end
