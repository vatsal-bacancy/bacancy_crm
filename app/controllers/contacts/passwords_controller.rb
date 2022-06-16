# frozen_string_literal: true

class Contacts::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    sign_out
    super
    if(params[:project_contact].present?)
      @project_contact = ProjectContact.find(params[:project_contact])
      if @project_contact.present?
        @project_contact.update(status: true)
      end
    end
  end

  # PUT /resource/password
  def update
    super
  end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
