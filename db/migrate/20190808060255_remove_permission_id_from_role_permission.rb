class RemovePermissionIdFromRolePermission < ActiveRecord::Migration[5.1]
  def change
    remove_column :role_permissions, :permission_id
    add_reference :role_permissions, :klass, index: true
  end
end
