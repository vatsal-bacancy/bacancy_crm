class UserPermission < ApplicationRecord
  belongs_to :user
  # belongs_to :klass
  # DISABLED = {'Invoice'=> ['update']}

  def self.is_disabled?(klass, action)
    # DISABLED[klass.name].try(:include?, action.name) ? true : false
    false
  end

end
