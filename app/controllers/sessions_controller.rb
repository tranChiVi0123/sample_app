class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      login_in user
      remember user
      redirect_to user
    else
      flash.now[:danger] = I18n.t(:invalid_email_combination)
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
