module Panel
  class BookingsController < BaseController
    def index
      @date = begin
        Date.parse(params[:date].to_s)
      rescue ArgumentError, TypeError
        Date.current
      end
      @bookings = @wash.bookings.includes(:service)
                       .where(date: @date)
                       .order(:slot)
      @counts = @wash.bookings.where(date: @date).group(:status).count
    end

    def update
      booking = @wash.bookings.find(params[:id])
      new_status = params[:status]
      if %w[tasdiqlandi bajarildi bekor].include?(new_status)
        booking.update!(status: new_status)
        redirect_to panel_bookings_path(date: booking.date),
          notice: "Bron #{booking.code}: #{booking.status_label.downcase}"
      else
        redirect_to panel_bookings_path, alert: "Noto'g'ri holat"
      end
    end
  end
end
