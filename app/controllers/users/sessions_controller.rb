# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include Users::TwoFactorAuthentication
  include Accessible
  skip_before_action :check_user, only: :destroy

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    # if tfa_user_remembered? || !signed_in?
    #   super
    #   return
    # end
    # tfa_user_sign_in!(current_user)
    # redirect_to new_users_two_factor_authentication_path
    super
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
