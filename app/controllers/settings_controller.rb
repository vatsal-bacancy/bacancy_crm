class SettingsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def users_settings
  end

  def email
  end

  def revoke_mail_access
    if current_user.ms_azure_token
      current_user.update_attributes(ms_azure_token: nil)
      flash[:notice] = "You have successfully removed your Microsoft Outlook account."

    elsif current_user.google_access_token
      uri = URI('https://accounts.google.com/o/oauth2/revoke')
      params = { :token => current_user.google_access_token }
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get(uri)
      current_user.update_attributes(google_access_token: nil, google_code: nil, google_access_token: nil, google_refresh_token: nil, google_token_expired_at: nil)
      flash[:notice] = "You have successfully removed your Gmail account."

    end
    redirect_to email_settings_path
  end

  def module
    @klasses = Klass.all
    @lead_klass = @klasses.find{|k| k.name == 'Lead'}
    @groups = Group.includes(:fields, :klass).all
    @lead_groups = @groups.select{|g| g.klass == @lead_klass}
    if params[:klass_id].present?
      @klass = Klass.find(params[:klass_id])
      @current_groups = @groups.select{|g| g.klass == @klass}
    end
  end

  def actions
    @klass = Klass.find(params[:klass_id])
    @url = params[:url]
  end

  def module_select
    @klass = Klass.find_by(name: params[:klass_name])
    @groups = @klass.groups.includes(:fields, :klass)
  end
end
