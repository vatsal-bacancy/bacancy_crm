module UserPermissionsHelper
  def checked_permission?(user, klass_id, action_id)
    return true if user.is_super_admin?
    user.user_permission.permissions.include?({"klass_id"=> klass_id, "action_id"=> action_id})
  end
end
