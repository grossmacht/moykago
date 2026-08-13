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

      case new_status
      when "bajarildi"
        payment_method = params[:payment_method]
        unless Booking.payment_methods.key?(payment_method)
          redirect_to panel_bookings_path(date: booking.date), alert: "To'lov usulini tanlang" and return
        end
        booking.complete!(payment_method: payment_method)
      when "tasdiqlandi", "bekor"
        booking.update!(status: new_status)
      else
        redirect_to panel_bookings_path, alert: "Noto'g'ri holat" and return
      end

      redirect_to panel_bookings_path(date: booking.date),
        notice: "Bron #{booking.code}: #{booking.status_label.downcase}"
    end
  end
end
