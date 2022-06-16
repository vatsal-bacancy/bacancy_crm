# Future replacement for all role based permission
class RoleResource < ApplicationRecord
  belongs_to :role
  belongs_to :action
  belongs_to :resource, polymorphic: true
end
