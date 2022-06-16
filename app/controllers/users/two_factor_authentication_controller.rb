class Users::TwoFactorAuthenticationController < ApplicationController
  include Users::TwoFactorAuthentication
  before_action :authenticate_tfa_user!

  def new
    tfa_current_user
  end

  def show
    tfa_current_user
    phone_number
    tfa_current_user.send_direct_otp(phone_number)
  end

  def create
    if tfa_current_user.verify_direct_otp(direct_otp)
      tfa_user_sign_out!(tfa_current_user)
      tfa_user_remember_me! if tfa_user_remember_me
      redirect_to root_path
    else
      phone_number
      flash.now[:danger] = 'Invalid OTP'
      render :show
    end
  end

  def resend_direct_otp
    tfa_current_user.send_direct_otp(phone_number)
    flash[:success] = 'OTP Sent'
  end

  private

  def tfa_user_remember_me
    @tfa_user_remember_me ||= (params[:tfa_user_remember_me] == 'on')
  end

  def phone_number
    @phone_number ||= params[:phone_number]
  end

  def direct_otp
    @direct_otp ||= params[:direct_otp]
  end

  def authenticate_tfa_user!
    return if tfa_user_signed_in?
    redirect_to new_user_session_path
  end

  # Spoof as devise controller, to reuse registration layout
  # @overload
  def devise_controller?
    true
  end
end
