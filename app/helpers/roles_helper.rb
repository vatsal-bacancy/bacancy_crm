module RolesHelper

  def is_checked?(role_permissions, klass, action)
    role_permissions.select{|role_permission| role_permission.klass_id == klass.id && role_permission.action_id == action.id}.count > 0
  end

  def any_role_resource_with_action?(role, action, resource)
    role.role_resources.where(action: action, resource: resource).any?
  end

end
