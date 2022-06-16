class Contract::Contract < ApplicationRecord
  belongs_to :contractable, polymorphic: true
  belongs_to :user

  after_save :send_email

  def templates
    Contract::Template.all
  end

  def self.of(contractable_type)
    where(contractable_type: contractable_type)
  end

  private

  def send_email
    Contract::BaseWorker.perform_async(
      to: contractable.company_email,
      cc: user.email,
      bcc: nil,
      subject: title,
      body: description
    )
  end
end
