class LeadClientContact < ApplicationRecord
  belongs_to :contact, dependent: :destroy
  belongs_to :contactable, polymorphic: true
end
