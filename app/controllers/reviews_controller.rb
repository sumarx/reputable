class ReviewsController < ApplicationController
  include Pagy::Method
  before_action :resume_session
  before_action :set_review, only: [:show, :generate_reply]

  def index
    @reviews = filter_reviews
    @pagy, @reviews = pagy(@reviews.includes(:location, :reply_drafts), limit: 20)
    @filter_params = filter_params
  end

  def show
    @reply_drafts = @review.reply_drafts.order(:created_at)
  end

  def generate_reply
    tone = params[:tone] || "professional"
    GenerateReplyJob.perform_later(@review, tone)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @review, notice: "AI reply drafts are being generated..." }
    end
  end

  private

  def set_review
    @review = Current.account.reviews.find(params[:id])
  end

  def filter_reviews
    reviews = Current.account.reviews.recent

    if filter_params[:platform].present?
      reviews = reviews.by_platform(filter_params[:platform])
    end

    if filter_params[:sentiment].present?
      reviews = reviews.by_sentiment(filter_params[:sentiment])
    end

    if filter_params[:rating].present?
      reviews = reviews.with_rating(filter_params[:rating])
    end

    if filter_params[:location_id].present?
      reviews = reviews.where(location_id: filter_params[:location_id])
    end

    if filter_params[:reply_status].present?
      case filter_params[:reply_status]
      when 'replied'
        reviews = reviews.replied
      when 'unreplied'
        reviews = reviews.unreplied
      end
    end

    reviews
  end

  def filter_params
    params.permit(:platform, :sentiment, :rating, :location_id, :reply_status, :date_from, :date_to)
  end
end