module AuthHelper

  # App's client ID. Register the app in Application Registration Portal to get this value.
  CLIENT_ID = ENV['MS_CLIENT_ID']
  # App's client secret. Register the app in Application Registration Portal to get this value.
  CLIENT_SECRET = ENV['MS_CLIENT_SECRET']


  # Scopes required by the app
  SCOPES = %w(openid profile offline_access User.Read Mail.Read Mail.Send Mail.ReadWrite email)

  REDIRECT_URI = "#{ENV['HOST_URL']}/authorize" # Temporary!

  # Generates the login URL for the app.
  def get_login_url
    client = OAuth2::Client.new(CLIENT_ID,
                                CLIENT_SECRET,
                                :site => 'https://login.microsoftonline.com',
                                :authorize_url => '/common/oauth2/v2.0/authorize',
                                :token_url => '/common/oauth2/v2.0/token')

    login_url = client.auth_code.authorize_url(:redirect_uri => REDIRECT_URI, :scope => SCOPES.join(' '))
  end

  def get_token_from_code(auth_code)
    client = OAuth2::Client.new(CLIENT_ID,
                                CLIENT_SECRET,
                                :site => 'https://login.microsoftonline.com',
                                :authorize_url => '/common/oauth2/v2.0/authorize',
                                :token_url => '/common/oauth2/v2.0/token')

    token = client.auth_code.get_token(auth_code,
                                       :redirect_uri => authorize_url,
                                       :scope => SCOPES.join(' '))
  end


  def google_login_url(state: '')
    client_secrets = Google::APIClient::ClientSecrets.load
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      scope: "https://mail.google.com https://www.googleapis.com/auth/calendar",
      redirect_uri: "#{ENV['HOST_URL']}/oauth2callback",
      state: Base64.encode64(state),
      additional_parameters: {
        prompt: :consent,
        access_type: :offline,
        include_granted_scopes: true
      }
    )
    auth_client.authorization_uri.to_s
  end

  # Gets the current access token
  def get_access_token
    # Get the current token hash from session
    token_hash = current_user.ms_azure_token
    client = OAuth2::Client.new(CLIENT_ID,
                                CLIENT_SECRET,
                                :site => 'https://login.microsoftonline.com',
                                :authorize_url => '/common/oauth2/v2.0/authorize',
                                :token_url => '/common/oauth2/v2.0/token')

    token = OAuth2::AccessToken.from_hash(client, token_hash)

    # Check if token is expired, refresh if so
    if token.expired?
      new_token = token.refresh!
      # Save new token
      session[:azure_token] = new_token.to_hash
      current_user.update(ms_azure_token: new_token.to_hash)
      access_token = new_token.token
    else
      access_token = token.token
    end
  end


  def get_google_access_token
    if current_user.google_token_expired?
      client_secrets = Google::APIClient::ClientSecrets.load
      auth_client = client_secrets.to_authorization
      auth_client.update!(
        scope: "https://mail.google.com https://www.googleapis.com/auth/calendar",
        refresh_token: current_user.google_refresh_token,
        grant_type: :refresh_token,
        additional_parameters: {
          access_type: :offline,
          include_granted_scopes: true
        }
      )
      auth_client.fetch_access_token!
      current_user.update(google_access_token: auth_client.access_token, google_token_expired_at: auth_client.expires_at)
    end
    current_user.google_access_token
  end

end
