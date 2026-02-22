class LocationsController < ApplicationController
  before_action :resume_session
  before_action :set_location, only: [:show, :edit, :update, :destroy, :sync_reviews]

  def index
    @locations = Current.account.locations.includes(:reviews, :platform_connections)
  end

  def show
    @reviews = @location.reviews.recent.limit(10)
    @platform_connections = @location.platform_connections
  end

  def new
    @location = Current.account.locations.build
  end

  def create
    @location = Current.account.locations.build(location_params)
    
    if @location.save
      redirect_to @location, notice: 'Location was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @location.update(location_params)
      redirect_to @location, notice: 'Location was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def sync_reviews
    SyncReviewsJob.perform_later(@location)
    redirect_to @location, notice: "Review sync has been queued. New reviews will appear shortly."
  end

  def destroy
    @location.destroy
    redirect_to locations_path, notice: 'Location was successfully deleted.'
  end

  private

  def set_location
    @location = Current.account.locations.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :address, :city, :country, :phone, :google_place_id, :facebook_page_id, :tripadvisor_id, :latitude, :longitude, :auto_generate_replies, :default_reply_tone, :auto_post_replies)
  end
end