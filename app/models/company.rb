class Company < ApplicationRecord
  has_many :directories, as: :directoriable, dependent: :destroy

  mount_uploader :big_logo, AttachmentUploader
  mount_uploader :small_logo, AttachmentUploader
  mount_uploader :fevicon_logo, AttachmentUploader

  # TODO: Use `User` reference instead
  def user
    User.find_by(email: ENV['ADMIN_EMAIL'])
  end

  def big_image
    #logo-left --> with white bg
    self.big_logo.present? ? "#{self.big_logo.url}?_=#{Time.now.to_i}" : 'bacancy-logo-black.svg'
  end

  def small_image
    self.small_logo.present? ? "#{self.small_logo.url}?_=#{Time.now.to_i}" : 'iPos-logo-white.svg'
  end

  def white_background_image
    :"bacancy_white_logo.svg"
  end

  def fevicon_image
    self.fevicon_logo.present? ? "#{self.fevicon_logo.url}?_=#{Time.now.to_i}" : 'favicon.png'
  end
end
