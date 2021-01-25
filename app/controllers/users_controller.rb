class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    # redirect_to(root_url) && return unless @user.activated = true
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def create
    @user = User.new(user_params) # Not the final implementation!
    if @user.save
      @user.send_activation_email params[:locale]
      flash[:info] = I18n.t(:please_check_your_mail)
      redirect_to root_url
    else
      flash.now[:danger] = I18n.t(:message_fail)
      render :new
    end
  end

  def edit
    @user = User.find_by(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      store_location
      flash.now[:success] = I18n.t(:profile_updated)
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash.now[:success] = I18n.t(:delete_user)
    redirect_to users_url
  end

  def following
    @title = t "following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render :show_follow
  end

  def followers
    @title = t "follower"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render :show_follow
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  # def logged_in_user
  #   unless logged_in?
  #     flash[:danger] = I18n.t(:please_log_in)
  #     redirect_to login_url
  #   end
  # end

  def correct_user
    @user = User.find_by(id: params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
