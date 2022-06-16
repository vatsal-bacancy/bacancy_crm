class Vendor < ApplicationRecord
  belongs_to :assigned_to, class_name: 'User'

  has_many :lead_client_contacts, as: :contactable, dependent: :destroy
  has_many :contacts, through: :lead_client_contacts
  has_many :inventories, dependent: :destroy

  accepts_nested_attributes_for :contacts

  def self.klass
    Klass.find_by(name: self.klass_name)
  end

  def self.klass_name
    'Vendor'
  end
end
