class CustomersController < ApplicationController
  before_action :require_customer, only: :show

  def new
    redirect_to customer_dashboard_path if current_customer
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)
    if params[:referral_code].present?
      @customer.referred_by = Customer.find_by(referral_code: params[:referral_code].to_s.strip.upcase)
    end
    if @customer.save
      session[:customer_id] = @customer.id
      redirect_to customer_dashboard_path, notice: t("customers.new.welcome", name: @customer.name)
    else
      flash.now[:alert] = @customer.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @bookings = current_customer.bookings.includes(:wash, :service).order(date: :desc, slot: :desc)
    @cars = current_customer.cars.order(:created_at)
  end

  private

  def customer_params
    params.require(:customer).permit(:name, :phone, :password)
  end
end
