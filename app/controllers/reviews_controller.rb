class ReviewsController < ApplicationController
  include Pagy::Method
  before_action :resume_session
  before_action :set_review, only: [:show, :generate_reply, :manual_post]

  def index
    @reviews = filter_reviews
    @pagy, @reviews = pagy(@reviews.includes(:location, :reply_drafts), limit: 20)
    @filter_params = filter_params
  end

  def show
    @reply_drafts = @review.reply_drafts.order(:created_at)
  end

  def manual_post
    unless @review.reply.present?
      redirect_to @review, alert: "No reply to post."
      return
    end
  end

  def generate_reply
    if @review.reply_drafts.draft.any?
      redirect_url = params[:redirect_to].presence || review_path(@review)
      redirect_to redirect_url, notice: "Reply drafts already exist for this review.", status: :see_other
      return
    end

    tone = params[:tone] || "professional"
    GenerateReplyJob.perform_later(@review, tone)

    redirect_url = params[:redirect_to].presence || review_path(@review)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to redirect_url, notice: "Generating AI replies — they'll appear in a few seconds...", status: :see_other }
    end
  end

  private

  def set_review
    @review = Current.account.reviews.find(params[:id])
  end

  def filter_reviews
    reviews = Current.account.reviews.recent

    # Apply global location filter from sidebar
    if @current_location && filter_params[:location_id].blank?
      reviews = reviews.where(location_id: @current_location.id)
    end

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