class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  
  def new
    @account = Account.new
    @user = User.new
  end

  def create
    @account = Account.new(account_params)
    @user = @account.users.build(user_params)

    if @account.save && @user.save
      start_new_session_for(@user)
      redirect_to dashboard_path, notice: "Welcome to RepuTable! Your account has been created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:account).permit(:name)
  end

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :name)
  end
end