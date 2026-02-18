class ReviewMailer < ApplicationMailer
  def negative_review_alert(campaign_response, user)
    @response = campaign_response
    @campaign = campaign_response.campaign
    @location = @campaign.location
    @user = user

    mail(
      to: user.email_address,
      subject: "⚠️ Negative Review Alert — #{@location.name}"
    )
  end

  def daily_digest(account, user)
    @account = account
    @user = user
    @date = Date.current
    @responses = CampaignResponse
      .joins(campaign: :location)
      .where(campaigns: { account_id: account.id })
      .where(created_at: @date.all_day)

    @total = @responses.count
    @negative_count = @responses.where(outcome: %w[private negative]).count
    @positive_count = @responses.where(outcome: %w[redirect positive]).count

    return if @total.zero?

    mail(
      to: user.email_address,
      subject: "📊 Daily Review Digest — #{@account.name} (#{@date.strftime('%b %d')})"
    )
  end
end
