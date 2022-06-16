class Employee < ApplicationRecord
  belongs_to :client
  has_many :employee_feedback_answers, dependent: :destroy
  has_many :feedback_questions, through: :employee_feedback_answers

  validates :phone_number, uniqueness: { scope: :country_code }

  def send_feedback_link
    country_code_and_phone_number = self.country_code + self.phone_number
    url = 'https://iposcrm.com'
    SMSWorker.perform_async(to: country_code_and_phone_number, body: "You've successfully completed Training with iPos.\nPlease give your feedback on #{url}#{Rails.application.routes.url_helpers.employee_feedbacks_path}")
  end

  def send_feedback_otp
    otp = rand(1000...9999).to_s
    update!(feedback_otp: otp)
    country_code_and_phone_number = self.country_code + self.phone_number
    SMSWorker.perform_async(to: country_code_and_phone_number, body: "Your OTP for iPos Feedback Form is #{otp}")
  end

  def verify_feedback_otp(otp)
    if self.feedback_otp == otp
      update!(feedback_otp: nil)
      return true
    end
    false
  end
end
