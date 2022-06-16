class ApplicationCipher

  class << self
    def encrypt(message, expires_in)
      encryptor.encrypt_and_sign(message, expires_in: expires_in)
    end

    def decrypt(message)
      encryptor.decrypt_and_verify(message)
    end

    private

    def encryptor
      @encryptor ||= ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31], cipher: 'aes-256-gcm')
    end
  end
end
