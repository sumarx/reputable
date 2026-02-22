class SettingsController < ApplicationController
  before_action :resume_session

  def show
    @account = Current.account
    @user = Current.user
    @notification_settings = Current.user.notification_settings || Current.user.create_notification_settings
  end

  def update
    @account = Current.account
    @user = Current.user
    @notification_settings = Current.user.notification_settings

    account_updated = @account.update(account_params) if params[:account].present?
    user_updated = @user.update(user_params) if params[:user].present?
    notification_updated = @notification_settings.update(notification_params) if params[:notification_settings].present?

    if account_updated != false && user_updated != false && notification_updated != false
      redirect_to settings_path, notice: "Settings updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:account).permit(:name, :notify_slack, :slack_webhook_url, :brand_description, :brand_reply_guidelines, :brand_always_mention, :brand_never_say, :brand_sample_replies)
  end

  def user_params
    params.require(:user).permit(:name, :email_address)
  end

  def notification_params
    params.require(:notification_settings).permit(:email_on_negative, :email_daily_digest)
  end
end
