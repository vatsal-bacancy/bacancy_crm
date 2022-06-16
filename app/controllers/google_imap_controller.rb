class GoogleImapController < ApplicationController
  before_action :authenticate_user!

  def authentication
    client_secrets = Google::APIClient::ClientSecrets.load
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      :scope => "https://mail.google.com/, https://www.googleapis.com/auth/userinfo.email",
      :redirect_uri => "#{ENV['HOST_URL']}/oauth2callback",
      :additional_parameters => {
      :access_type => "offline",         # offline access
      :include_granted_scopes => "true"  # incremental auth
      }
    )
    auth_uri = auth_client.authorization_uri.to_s
  end

  def callback
    if params[:code].present?
      client_secrets = Google::APIClient::ClientSecrets.load
      auth_client = client_secrets.to_authorization
      auth_client.code = params[:code]
      auth_client.update!(
        scope: "https://mail.google.com https://www.googleapis.com/auth/calendar",
        redirect_uri: "#{ENV['HOST_URL']}/oauth2callback",
        grant_type: :authorization_code,
        additional_parameters: {
          access_type: :offline,
          include_granted_scopes: true
        }
      )
      current_user.update_attributes(google_code: params[:code])
      auth_client.fetch_access_token!
      uri = URI("https://www.googleapis.com/gmail/v1/users/me/profile?access_token=#{auth_client.access_token}")
      response =  JSON.parse(Net::HTTP.get(uri))
      current_user.update_attributes(google_access_token: auth_client.access_token, google_refresh_token: auth_client.refresh_token, google_email: response["emailAddress"], google_token_expired_at: auth_client.expires_at)
      if params[:state].present?
        redirect_to Base64.decode64(params[:state])
      else
        redirect_to emails_path
      end
    end
  end


  def access_token
    auth_client.update!(
      :additional_parameters => {"access_type" => "offline"}
    )
  end
  def get_access_code
  end
end
