module Users::TwoFactorAuthentication

  TFA_USER_KEY = ENV['TFA_USER_KEY']
  TFA_USER_REMEMBER_ME_KEY = ENV['TFA_USER_REMEMBER_ME_KEY']

  def tfa_user_signed_in?
    session[TFA_USER_KEY].present?
  end

  def tfa_user_id
    session[TFA_USER_KEY]
  end

  def tfa_user_id!(id)
    if id.nil?
      session.delete(TFA_USER_KEY)
      return
    end
    session[TFA_USER_KEY] = id
  end

  def tfa_current_user
    @tfa_current_user ||= (tfa_user_signed_in? ? User.find(tfa_user_id) : nil)
  end

  def tfa_user_sign_in!(user)
    sign_out(user)
    tfa_user_id!(user.id)
    @tfa_current_user = user
  end

  def tfa_user_sign_out!(user)
    sign_in(user)
    tfa_user_id!(nil)
    @tfa_current_user = nil
  end

  def tfa_user_remember_me!
    cookies.signed[TFA_USER_REMEMBER_ME_KEY] = { value: true, expires: 1.months.from_now }
  end

  def tfa_user_remembered?
    !!cookies.signed[TFA_USER_REMEMBER_ME_KEY]
  end
end
