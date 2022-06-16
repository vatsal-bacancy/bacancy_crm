class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.find_by_encrypted_id(id)
    self.find(ApplicationCipher.decrypt(id))
  end

  def encrypted_id
    @encrypted_id ||= ApplicationCipher.encrypt(self.id, 1.year)
  end
end
