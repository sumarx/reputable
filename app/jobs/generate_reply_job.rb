class GenerateReplyJob < ApplicationJob
  queue_as :default

  def perform(review, tone = "professional")
    return unless review.is_a?(Review)

    # Set the tenant for multi-tenancy
    ActsAsTenant.with_tenant(review.account) do
      generator = Replies::Generator.new(review, tone: tone)
      reply_options = generator.call

      # Create reply drafts for each generated option
      reply_options.each do |reply_text|
        review.reply_drafts.create!(
          body: reply_text,
          tone: tone,
          status: 'draft'
        )
      end

      Rails.logger.info "Generated #{reply_options.size} reply drafts for review #{review.id}"

      # Broadcast updated drafts to the review page
      # Note: forms in broadcast HTML won't have valid CSRF tokens.
      # Client-side JS will inject the page's CSRF token after Turbo updates the DOM.
      drafts = review.reply_drafts.order(:created_at)
      html = ApplicationController.render(
        partial: "reviews/reply_drafts",
        locals: { reply_drafts: drafts }
      )
      wrapped = "<div class=\"bg-white rounded-lg shadow-sm border border-gray-200 p-6\">#{html}</div>"
      Turbo::StreamsChannel.broadcast_update_to(
        review, "reply_drafts",
        target: "reply_drafts",
        html: wrapped
      )
    end
  rescue => error
    Rails.logger.error "GenerateReplyJob failed for review #{review.id}: #{error.message}"
    raise error
  end
end