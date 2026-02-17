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
    end
  rescue => error
    Rails.logger.error "GenerateReplyJob failed for review #{review.id}: #{error.message}"
    raise error
  end
end