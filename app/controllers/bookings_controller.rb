class BookingsController < ApplicationController
  def create
    @wash = Wash.find(booking_params[:wash_id])
    @booking = @wash.bookings.new(booking_params.except(:wash_id, :promo_code, :use_bonus))
    @booking.customer = current_customer if current_customer
    apply_discount

    if @booking.save
      finalize_discount!
      notice = "Broningiz qabul qilindi! Kod: #{@booking.code}"
      notice += " Promo-kod topilmadi yoki muddati o'tgan, chegirmasiz qabul qilindi." if @promo_error
      redirect_to booking_status_path(@booking.code), notice: notice
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
      :customer_name, :customer_phone, :car_model, :car_id,
      :promo_code, :use_bonus
    )
  end

  # Bron yaratilayotganda qo'llaniladi — promo-kod yoki bonus balansidan
  # faqat bittasi ishlatiladi (aralashtirilmaydi).
  def apply_discount
    price = Service.find_by(id: @booking.service_id)&.price
    return unless price

    promo_input = booking_params[:promo_code]
    if promo_input.present?
      promo = PromoCode.find_by(code: promo_input.to_s.strip.upcase)
      if promo&.usable?(price)
        @booking.promo_code = promo
        @booking.discount_amount = promo.discount_for(price)
      else
        @promo_error = true
      end
    elsif booking_params[:use_bonus] == "1" && current_customer&.bonus_balance.to_i.positive?
      @use_bonus_amount = [ current_customer.bonus_balance, price ].min
      @booking.discount_amount = @use_bonus_amount
    end
  end

  def finalize_discount!
    if @booking.promo_code
      @booking.promo_code.increment!(:used_count)
    elsif @use_bonus_amount
      current_customer.decrement!(:bonus_balance, @use_bonus_amount)
    end
  end
end
