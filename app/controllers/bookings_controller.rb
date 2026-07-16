class BookingsController < ApplicationController
  def create
    @wash = Wash.find(booking_params[:wash_id])
    @booking = @wash.bookings.new(booking_params.except(:wash_id))

    if @booking.save
      redirect_to booking_status_path(@booking.code),
        notice: "Broningiz qabul qilindi! Kod: #{@booking.code}"
    else
      redirect_to wash_path(@wash,
          date: booking_params[:date],
          service_id: booking_params[:service_id],
          customer_name: booking_params[:customer_name],
          customer_phone: booking_params[:customer_phone],
          car_model: booking_params[:car_model],
          anchor: "bron"),
        alert: @booking.errors.full_messages.to_sentence
    end
  end

  def show
    @booking = Booking.includes(:wash, :service).find_by!(code: params[:code])
  end

  def cancel
    @booking = Booking.find_by!(code: params[:code])
    if @booking.cancellable?
      @booking.bekor!
      redirect_to booking_status_path(@booking.code), notice: "Bron bekor qilindi"
    else
      redirect_to booking_status_path(@booking.code), alert: "Bu bronni bekor qilib bo'lmaydi"
    end
  end

  def lookup
    if params[:phone].present?
      phone = params[:phone].gsub(/[^\d+]/, "")
      @bookings = Booking.includes(:wash, :service)
                         .where(customer_phone: phone)
                         .order(date: :desc, slot: :desc)
    end
  end

  private

  def booking_params
    params.require(:booking).permit(
      :wash_id, :service_id, :date, :slot,
      :customer_name, :customer_phone, :car_model
    )
  end
end
