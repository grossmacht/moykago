module Admin
  class DashboardController < ApplicationController
    before_action :require_admin

    def index
      @wash_count = Wash.count
      @today_count = Booking.where(date: Date.current).count
      month = Date.current.beginning_of_month..Date.current.end_of_month
      month_bookings = Booking.where(date: month)
      @month_count = month_bookings.count
      @month_gmv = month_bookings.where.not(status: :bekor)
                                 .joins(:service).sum("services.price")
      @recent = Booking.includes(:wash, :service).order(created_at: :desc).limit(10)
      @by_wash = Booking.where(date: month).group(:wash_id).count
    end
  end
end
