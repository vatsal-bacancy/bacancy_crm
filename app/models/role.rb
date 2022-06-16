class Role < ApplicationRecord
  audited
  scopify

  belongs_to :resource, polymorphic: true, optional: true

  has_and_belongs_to_many :users, :join_table => :users_roles
  has_many :role_permissions, dependent: :destroy
  has_many :role_resources, dependent: :destroy
  validates :resource_type, inclusion: {in: Rolify.resource_types}, allow_nil: true

  def readable_resources
    role_resources.where(action: Action.get_read)
  end

  def readable_root_groups(klass:)
    klass.groups.root_groups.where(role_resources: readable_resources)
  end

  def any_users_exists?
    users.any?
  end
end
