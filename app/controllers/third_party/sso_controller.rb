class ThirdParty::SsoController < ApplicationController

  def create
    if !user_signed_in? && (user = User.find_by(email: payload[:user_email])).present?
      sign_in(user)
    end
    redirect_to payload[:redirect_to]
  end

  private

  def payload
    @payload ||= SharedCipher.decrypt(params[:payload])
  end
end
