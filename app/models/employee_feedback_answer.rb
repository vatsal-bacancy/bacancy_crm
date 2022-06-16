class EmployeeFeedbackAnswer < ApplicationRecord
  belongs_to :employee
  belongs_to :feedback_question
end
