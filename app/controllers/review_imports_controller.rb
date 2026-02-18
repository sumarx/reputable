class ReviewImportsController < ApplicationController
  before_action :resume_session

  def new
    @locations = Current.account.locations.order(:name)
  end

  def create
    if params[:import_type] == "csv"
      import_csv
    else
      import_single
    end
  end

  private

  def import_single
    location = Current.account.locations.find(params[:location_id])
    external_id = Digest::SHA256.hexdigest("manual:#{params[:reviewer_name]}:#{Time.current.to_i}:#{rand(10000)}")[0..63]

    review = location.reviews.new(
      account: Current.account,
      platform: params[:platform],
      external_review_id: external_id,
      reviewer_name: params[:reviewer_name],
      rating: params[:rating].to_i,
      body: params[:body],
      published_at: params[:published_at].present? ? params[:published_at] : Time.current,
      reply_status: "pending"
    )

    if review.save
      redirect_to reviews_path, notice: "Review imported successfully."
    else
      @locations = Current.account.locations.order(:name)
      flash.now[:alert] = "Failed to import: #{review.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end

  def import_csv
    file = params[:csv_file]
    unless file.present?
      @locations = Current.account.locations.order(:name)
      flash.now[:alert] = "Please select a CSV file."
      render :new, status: :unprocessable_entity
      return
    end

    require "csv"
    created = 0
    errors = []
    location = Current.account.locations.find(params[:location_id])

    CSV.parse(file.read, headers: true, liberal_parsing: true) do |row|
      external_id = Digest::SHA256.hexdigest("csv:#{row['reviewer_name']}:#{row['body'].to_s[0..50]}:#{row['published_at']}")[0..63]

      review = location.reviews.new(
        account: Current.account,
        platform: row["platform"]&.strip&.downcase,
        external_review_id: external_id,
        reviewer_name: row["reviewer_name"]&.strip,
        rating: row["rating"]&.to_i,
        body: row["body"]&.strip,
        published_at: row["published_at"].present? ? Time.parse(row["published_at"]) : Time.current,
        reply_status: "pending"
      )

      if review.save
        created += 1
      else
        errors << "Row #{created + errors.size + 1}: #{review.errors.full_messages.join(', ')}"
      end
    end

    msg = "Imported #{created} review#{'s' unless created == 1}."
    msg += " #{errors.size} failed." if errors.any?
    redirect_to reviews_path, notice: msg
  rescue CSV::MalformedCSVError => e
    @locations = Current.account.locations.order(:name)
    flash.now[:alert] = "Invalid CSV file: #{e.message}"
    render :new, status: :unprocessable_entity
  end
end
