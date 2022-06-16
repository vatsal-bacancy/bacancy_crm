class SharedCipher < ApplicationCipher
  class << self

    private

    def encryptor
      @encryptor ||= ActiveSupport::MessageEncryptor.new(Rails.application.secrets.shared_secret[0..31], cipher: 'aes-256-gcm')
    end
  end
end
