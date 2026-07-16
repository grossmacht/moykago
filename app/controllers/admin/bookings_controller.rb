module Admin
  class BookingsController < ApplicationController
    before_action :require_admin

    def index
      @status = params[:status].presence
      @bookings = Booking.includes(:wash, :service).order(created_at: :desc)
      @bookings = @bookings.where(status: @status) if @status
      @bookings = @bookings.limit(100)
    end
  end
end
