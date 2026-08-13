module Admin
  class DashboardController < ApplicationController
    before_action :require_admin

    def index
      @wash_count = Wash.count
      @today_count = Booking.where(date: Date.current).count
      month = Date.current.beginning_of_month..Date.current.end_of_month
      month_bookings = Booking.where(date: month)
      @month_count = month_bookings.count
      completed_this_month = month_bookings.where(status: :bajarildi)
      @month_gmv = completed_this_month.sum(:amount_charged)
      @month_commission = completed_this_month.sum(:commission_amount)
      @recent = Booking.includes(:wash, :service).order(created_at: :desc).limit(10)
      counts_by_wash_id = month_bookings.group(:wash_id).count
      @by_wash = Wash.where(id: counts_by_wash_id.keys).index_by(&:id)
                      .map { |id, w| [ w, counts_by_wash_id[id] ] }
                      .sort_by { |_, count| -count }
    end
  end
end
