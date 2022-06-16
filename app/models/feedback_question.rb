class FeedbackQuestion < ApplicationRecord
  has_many :employee_feedback_answers, dependent: :destroy
  has_many :employees, through: :employee_feedback_answers
end
