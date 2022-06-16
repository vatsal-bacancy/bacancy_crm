class TemplateDir < ApplicationRecord
  has_many :email_templetes
  belongs_to :user

end
