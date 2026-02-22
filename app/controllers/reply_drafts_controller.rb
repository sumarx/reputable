class ReplyDraftsController < ApplicationController
  before_action :resume_session
  before_action :set_reply_draft

  def update
    redirect_url = params[:redirect_to].presence || review_path(@reply_draft.review)
    if @reply_draft.update(reply_draft_params)
      redirect_to redirect_url, notice: "Reply draft updated."
    else
      redirect_to redirect_url, alert: "Could not update reply draft."
    end
  end

  def approve
    @reply_draft.update!(status: "approved")
    redirect_url = params[:redirect_to].presence || review_path(@reply_draft.review)
    redirect_to redirect_url, notice: "Reply approved! You can now send it."
  end

  def send_reply
    review = @reply_draft.review
    location = review.location

    # Try GBP API if connected
    if location.google_connected? && location.google_account_id.present? && location.google_location_id.present? && review.external_review_id.present?
      poster = Replies::GoogleBusinessPoster.new(review, @reply_draft.body)
      google_success = poster.call
    else
      google_success = false
    end

    review.update!(reply: @reply_draft.body, reply_status: google_success ? "sent" : "manual", replied_at: Time.current)
    @reply_draft.update!(status: "approved")

    if google_success
      redirect_to review, notice: "Reply posted to Google Business Profile successfully! ✓"
    else
      # Fallback: redirect to manual post page
      redirect_to manual_post_review_path(review)
    end
  end

  private

  def set_reply_draft
    @reply_draft = ReplyDraft.joins(review: :account).where(accounts: { id: Current.account.id }).find(params[:id])
  end

  def reply_draft_params
    params.require(:reply_draft).permit(:body, :tone, :status)
  end
end
