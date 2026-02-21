module Campaigns
  class AnalyticsService
    PERIODS = {
      "7d" => 7.days,
      "30d" => 30.days,
      "90d" => 90.days,
      "all" => nil
    }.freeze

    attr_reader :account, :period_key

    def initialize(account, period: "30d")
      @account = account
      @period_key = PERIODS.key?(period) ? period : "30d"
      @period_duration = PERIODS[@period_key]
    end

    def campaigns
      @campaigns ||= account.campaigns.includes(:location)
    end

    def responses
      @responses ||= begin
        scope = CampaignResponse.joins(:campaign).where(campaigns: { account_id: account.id })
        scope = scope.where("campaign_responses.created_at >= ?", period_start) if period_start
        scope
      end
    end

    def period_start
      @period_start ||= @period_duration&.ago
    end

    # === KPI Stats ===

    def total_responses
      responses.count
    end

    def total_redirected
      responses.where(outcome: "redirect").count
    end

    def total_clicked
      responses.where(clicked_external: true).count
    end

    def total_private
      responses.where(outcome: "private").count
    end

    def avg_rating
      responses.where.not(rating: nil).average(:rating)&.round(2) || 0
    end

    def conversion_rate
      return 0 if total_responses.zero?
      (total_redirected.to_f / total_responses * 100).round(1)
    end

    def click_through_rate
      return 0 if total_redirected.zero?
      (total_clicked.to_f / total_redirected * 100).round(1)
    end

    # === Funnel ===

    def funnel_data
      {
        responses: total_responses,
        redirected: total_redirected,
        clicked: total_clicked,
        private_feedback: total_private
      }
    end

    # === Charts ===

    def responses_over_time
      group_by_time(responses).count
    end

    def responses_by_rating
      responses.where.not(rating: nil).group(:rating).count.sort.to_h
    end

    def responses_by_outcome
      responses.group(:outcome).count
    end

    def responses_by_campaign
      campaigns.map do |c|
        scope = c.campaign_responses
        scope = scope.where("created_at >= ?", period_start) if period_start
        count = scope.count
        next if count.zero?

        redirected = scope.where(outcome: "redirect").count
        clicked = scope.where(clicked_external: true).count
        priv = scope.where(outcome: "private").count
        avg = scope.where.not(rating: nil).average(:rating)&.round(2) || 0

        {
          campaign: c,
          responses: count,
          redirected: redirected,
          clicked: clicked,
          private_feedback: priv,
          avg_rating: avg,
          conversion_rate: count > 0 ? (redirected.to_f / count * 100).round(1) : 0
        }
      end.compact.sort_by { |r| -r[:responses] }
    end

    def rating_trend
      group_by_time(responses.where.not(rating: nil)).average(:rating)
    end

    def sentiment_distribution
      # Based on rating vs campaign threshold
      positive = responses.joins(:campaign).where("campaign_responses.rating >= campaigns.positive_threshold").count
      negative = responses.joins(:campaign).where("campaign_responses.rating < campaigns.positive_threshold").count
      { "Happy (redirected)" => positive, "Needs attention" => negative }
    end

    def top_feedback(limit: 5)
      responses.where.not(feedback: [nil, ""]).order(created_at: :desc).limit(limit).includes(campaign: :location)
    end

    def hourly_distribution
      responses.group("EXTRACT(HOUR FROM campaign_responses.created_at)::int").count.sort.to_h
    end

    private

    def group_by_time(scope)
      if @period_key == "7d"
        scope.group_by_day("campaign_responses.created_at")
      elsif @period_key.in?(%w[30d 90d])
        scope.group_by_week("campaign_responses.created_at")
      else
        scope.group_by_month("campaign_responses.created_at")
      end
    end
  end
end
