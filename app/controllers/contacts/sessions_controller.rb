# frozen_string_literal: true

class Contacts::SessionsController < Devise::SessionsController
  include Accessible
  skip_before_action :check_user, only: :destroy
  #prepend_before_action :sign_out_existing_user
  #prepend_before_action :require_no_authentication, only: [:new]

  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  #   if(params[:project_contact].present?)
  #     @project_contact = ProjectContact.find(params[:project_contact])
  #     if @project_contact.present?
  #       @project_contact.update(status: true)
  #     end
  #   end
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

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
