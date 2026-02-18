class PagesController < ApplicationController
  allow_unauthenticated_access
  layout "landing"

  def home
    redirect_to dashboard_path if authenticated?
  end

  def privacy
  end

  def terms
  end

  def about
  end

  def contact
  end
end
