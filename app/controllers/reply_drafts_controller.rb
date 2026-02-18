class ReplyDraftsController < ApplicationController
  before_action :resume_session
  before_action :set_reply_draft

  def update
    if @reply_draft.update(reply_draft_params)
      redirect_to @reply_draft.review, notice: "Reply draft updated."
    else
      redirect_to @reply_draft.review, alert: "Could not update reply draft."
    end
  end

  def approve
    @reply_draft.update!(status: "approved")
    redirect_to @reply_draft.review, notice: "Reply draft approved."
  end

  def send_reply
    review = @reply_draft.review
    poster = Replies::GoogleBusinessPoster.new(review, @reply_draft.body)
    google_success = poster.call

    review.update!(reply: @reply_draft.body, reply_status: "sent", replied_at: Time.current)
    @reply_draft.update!(status: "approved")

    if google_success
      notice = "Reply sent successfully and posted to Google Business Profile."
    else
      notice = "Reply saved locally. Could not post to Google: #{poster.error}"
    end

    redirect_to review, notice: notice
  end

  private

  def set_reply_draft
    @reply_draft = ReplyDraft.joins(review: :account).where(accounts: { id: Current.account.id }).find(params[:id])
  end

  def reply_draft_params
    params.require(:reply_draft).permit(:body, :tone)
  end
end
