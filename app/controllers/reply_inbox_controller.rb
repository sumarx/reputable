class ReplyInboxController < ApplicationController
  include Pagy::Method
  before_action :resume_session

  def index
    reviews = Current.account.reviews.includes(:location, :reply_drafts)

    # Apply location filter
    if @current_location
      reviews = reviews.where(location_id: @current_location.id)
    end

    # Filter tabs
    @tab = params[:tab] || "needs_reply"
    reviews = case @tab
    when "needs_reply"
      reviews.unreplied.where(reply_drafts: { id: nil }).or(
        reviews.unreplied.where.not(id: ReplyDraft.select(:review_id))
      )
    when "drafted"
      reviews.where(reply_status: %w[draft pending]).where(id: ReplyDraft.where(status: "draft").select(:review_id))
    when "sent"
      reviews.replied
    else
      reviews.where.not(reply_status: %w[sent manual])
    end

    # Order: negative first (urgency), then by recency
    reviews = reviews.order(
      Arel.sql("CASE WHEN sentiment = 'negative' THEN 0 WHEN sentiment = 'neutral' THEN 1 ELSE 2 END"),
      published_at: :desc
    )

    @pagy, @reviews = pagy(reviews, limit: 15)
    @pending_count = Current.account.reviews.unreplied.count

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
