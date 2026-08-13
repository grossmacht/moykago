class ReviewsController < ApplicationController
  def create
    @wash = Wash.find(review_params[:wash_id])
    @review = @wash.reviews.new(review_params.except(:wash_id))

    if @review.save
      redirect_to wash_path(@wash, anchor: "sharhlar"), notice: t("washes.show.review_thanks")
    else
      redirect_to wash_path(@wash, anchor: "sharhlar"),
        alert: @review.errors.full_messages.to_sentence
    end
  end

  private

  def review_params
    params.require(:review).permit(:wash_id, :name, :rating, :comment, :before_photo, :after_photo)
  end
end
