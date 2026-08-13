module Panel
  class AnalyticsController < BaseController
    def show
      month = Date.current.beginning_of_month..Date.current.end_of_month
      @month_gmv = @wash.gmv_between(month)
      @month_commission = @wash.commission_owed_between(month)

      last14 = (Date.current - 13)..Date.current
      raw_daily = @wash.bookings.where(date: last14, status: :bajarildi).group(:date).sum(:amount_charged)
      @daily = last14.index_with { |d| raw_daily[d] || 0 }.transform_keys { |d| d.strftime("%d.%m") }

      @hourly = @wash.bookings.where(status: :bajarildi)
                     .group("substr(slot, 1, 2)").count.sort.to_h.transform_keys { |h| "#{h}:00" }
    end
  end
end
