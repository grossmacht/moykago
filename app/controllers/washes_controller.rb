class WashesController < ApplicationController
  def index
    @district = params[:district].presence
    @washes = Wash.includes(:services, :reviews).order(:name)
    @washes = @washes.where(district: @district) if @district
    @washes = @washes.to_a
    @lat = params[:lat].presence
    @lng = params[:lng].presence
    case params[:sort]
    when "narx"      then @washes.sort_by! { |w| w.price_from || 10**9 }
    when "reyting"   then @washes.sort_by! { |w| -(w.rating || 0) }
    when "eng_yaqin"
      if @lat && @lng
        @washes.sort_by! { |w| w.distance_km_from(@lat, @lng) || 10**9 }
      end
    end
  end

  def show
    @wash = Wash.includes(:services, reviews: :booking).find_by!(slug: params[:slug])
    @date = parse_date(params[:date])
    @booking = Booking.new(
      service_id: params[:service_id],
      customer_name: params[:customer_name],
      customer_phone: params[:customer_phone],
      car_model: params[:car_model]
    )
  end

  private

  def parse_date(value)
    date = Date.parse(value.to_s)
    date < Date.current ? Date.current : [ date, Date.current + 14 ].min
  rescue ArgumentError, TypeError
    Date.current
  end
end
