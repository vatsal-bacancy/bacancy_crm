class Klass < ApplicationRecord
  has_one :module_number, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :fields, dependent: :destroy
  has_many :module_numbers, dependent: :destroy
  has_many :role_permissions, dependent: :destroy
  has_many :work_flows, class_name: 'WorkFlows::WorkFlow'

  def constant
    @constant ||= self.name.constantize
  end
end
