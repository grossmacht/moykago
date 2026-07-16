class HomeController < ApplicationController
  def index
    @featured = Wash.includes(:services, :reviews).featured.limit(4)
    @featured = Wash.includes(:services, :reviews).limit(4) if @featured.empty?
    @wash_count = Wash.count
    @district_counts = Wash.group(:district).count
  end
end
