class RolePermission < ApplicationRecord
  audited
  belongs_to :role
  belongs_to :klass # permission
  belongs_to :action

  validate :validate_disabled



  # DISABLED = {'Invoice'=> ['update']}

  def validate_disabled
    errors.add(:base, 'Cant assign permission to disabled') if self.class.is_disabled?(self.klass, self.action)
  end

  def self.is_disabled?(klass, action)
    # DISABLED[klass.name].try(:include?, action.name) ? true : false
    false
  end

end
