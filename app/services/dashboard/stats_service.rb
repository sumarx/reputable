module Dashboard
  class StatsService
    PERIODS = {
      "7d" => 7.days,
      "30d" => 30.days,
      "90d" => 90.days,
      "12mo" => 365.days,
      "all" => nil
    }.freeze

    attr_reader :account, :period_key, :period_duration

    def initialize(account, period: "30d")
      @account = account
      @period_key = PERIODS.key?(period) ? period : "30d"
      @period_duration = PERIODS[@period_key]
    end

    def reviews
      @reviews ||= begin
        scope = account.reviews
        scope = scope.where("published_at >= ?", period_start) if period_duration
        scope
      end
    end

    def previous_reviews
      @previous_reviews ||= begin
        return account.reviews.none unless period_duration
        account.reviews.where(published_at: previous_period_start...period_start)
      end
    end

    def period_start
      @period_start ||= period_duration ? period_duration.ago : nil
    end

    def previous_period_start
      @previous_period_start ||= period_duration ? (period_duration * 2).ago : nil
    end

    # === KPI Stats ===

    def kpi_stats
      @kpi_stats ||= {
        total_reviews: total_reviews_with_trend,
        average_rating: average_rating_with_trend,
        response_rate: response_rate_with_trend,
        sentiment_score: sentiment_score_with_trend,
        new_reviews: new_reviews_count
      }
    end

    def total_reviews_with_trend
      current = reviews.count
      previous = previous_reviews.count
      { value: current, trend: calculate_trend(current, previous) }
    end

    def average_rating_with_trend
      current = reviews.where.not(rating: nil).average(:rating)&.round(2) || 0
      previous = previous_reviews.where.not(rating: nil).average(:rating)&.round(2) || 0
      { value: current, trend: calculate_trend(current, previous) }
    end

    def response_rate_with_trend
      current = calc_response_rate(reviews)
      previous = calc_response_rate(previous_reviews)
      { value: current, trend: calculate_trend(current, previous) }
    end

    def sentiment_score_with_trend
      current = calc_sentiment_score(reviews)
      previous = calc_sentiment_score(previous_reviews)
      { value: current, trend: calculate_trend(current, previous) }
    end

    def new_reviews_count
      reviews.count
    end

    # === Charts ===

    def rating_trend_data
      group_reviews_by_time(reviews.where.not(rating: nil)).average(:rating)
    end

    def sentiment_trend_data
      %w[positive neutral negative].map do |sentiment|
        { name: sentiment.capitalize, data: group_reviews_by_time(reviews.where(sentiment: sentiment)).count }
      end
    end

    def review_volume_data
      group_reviews_by_time(reviews).count
    end

    def rating_distribution
      total = reviews.where.not(rating: nil).count
      (1..5).reverse_each.map do |star|
        count = reviews.where(rating: star).count
        pct = total > 0 ? (count.to_f / total * 100).round(1) : 0
        { star: star, count: count, percentage: pct }
      end
    end

    def platform_distribution
      reviews.group(:platform).count
    end

    def sentiment_by_platform
      %w[positive neutral negative].map do |sentiment|
        { name: sentiment.capitalize, data: reviews.where(sentiment: sentiment).group(:platform).count }
      end
    end

    # === AI Insights ===

    def top_categories(limit: 10)
      # categories is a jsonb array column
      result = account.connection.execute(<<-SQL)
        SELECT cat, COUNT(*) as cnt
        FROM reviews, jsonb_array_elements_text(categories) AS cat
        WHERE account_id = #{account.id}
        #{"AND published_at >= '#{period_start.iso8601}'" if period_start}
        GROUP BY cat
        ORDER BY cnt DESC
        LIMIT #{limit}
      SQL
      result.to_a
    rescue => e
      Rails.logger.warn("Dashboard categories query failed: #{e.message}")
      []
    end

    def top_keywords_positive(limit: 5)
      extract_keywords(reviews.positive, limit)
    end

    def top_keywords_negative(limit: 5)
      extract_keywords(reviews.negative, limit)
    end

    # === Response Management ===

    def unreplied_count
      reviews.unreplied.count
    end

    def unreplied_negative_count
      reviews.unreplied.negative.count
    end

    def avg_response_time_hours
      replied = reviews.where.not(replied_at: nil).where.not(published_at: nil)
      return nil if replied.empty?

      avg_seconds = replied.average("EXTRACT(EPOCH FROM (replied_at - published_at))").to_f
      (avg_seconds / 3600).round(1)
    end

    def response_rate_by_platform
      platforms = reviews.group(:platform).count
      replied = reviews.replied.group(:platform).count

      platforms.map do |platform, total|
        rate = total > 0 ? (replied.fetch(platform, 0).to_f / total * 100).round(1) : 0
        { platform: platform, rate: rate, replied: replied.fetch(platform, 0), total: total }
      end
    end

    # === Recent Reviews ===

    def recent_reviews(limit: 10)
      reviews.recent.includes(:location).limit(limit)
    end

    def recent_reviews_needing_reply(limit: 10)
      reviews.unreplied.recent.includes(:location).limit(limit)
    end

    def recent_negative_reviews(limit: 10)
      reviews.negative.recent.includes(:location).limit(limit)
    end

    private

    def calc_response_rate(scope)
      total = scope.count
      return 0 if total.zero?
      replied = scope.replied.count
      ((replied.to_f / total) * 100).round(1)
    end

    def calc_sentiment_score(scope)
      with_sentiment = scope.where.not(sentiment_score: nil)
      return 0 if with_sentiment.empty?
      (with_sentiment.average(:sentiment_score) * 100).round(1)
    end

    def calculate_trend(current, previous)
      return nil if previous.nil? || previous == 0
      current = current.to_f
      previous = previous.to_f
      return nil if previous.zero?
      ((current - previous) / previous.abs * 100).round(1)
    end

    def group_reviews_by_time(scope)
      if period_key.in?(%w[7d 30d])
        scope.group_by_day(:published_at)
      elsif period_key == "90d"
        scope.group_by_week(:published_at)
      else
        scope.group_by_month(:published_at)
      end
    end

    def extract_keywords(scope, limit)
      # Simple word frequency from review bodies
      words = scope.where.not(body: nil).pluck(:body).join(" ").downcase
      words = words.gsub(/[^a-z\s]/, "").split(/\s+/)

      stopwords = %w[the a an and or but in on at to for of is it was were be been being have has had do does did will would shall should may might can could this that these those i me my we our you your he him his she her they them their what which who whom how when where why not no nor very just also more most other some any all each every both few many much own same so than too]

      words.reject! { |w| w.length < 3 || stopwords.include?(w) }
      words.tally.sort_by { |_, count| -count }.first(limit)
    end
  end
end
