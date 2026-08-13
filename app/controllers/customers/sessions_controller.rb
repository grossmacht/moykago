module Customers
  class SessionsController < ApplicationController
    def new
      redirect_to customer_dashboard_path if current_customer
    end

    def create
      customer = Customer.find_by(phone: params[:phone].to_s.gsub(/[^\d+]/, ""))
      if customer&.authenticate(params[:password])
        session[:customer_id] = customer.id
        redirect_to customer_dashboard_path
      else
        flash.now[:alert] = t("customers.sessions.invalid")
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:customer_id)
      redirect_to root_path, notice: t("customers.sessions.logged_out")
    end
  end
end
