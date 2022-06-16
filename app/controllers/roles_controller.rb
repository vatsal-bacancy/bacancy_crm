# TODO: Remove All role permission based table and use RoleResource as replacement
class RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user!

  def index
    @roles = Role.all
  end

  def new
    @role = Role.new
    @actions = Action.all
    @klasses = Klass.where.not(name: ['Message', 'Company']).order(:name)
  end

  def edit
    @role = Role.find(params[:id])
    @actions = Action.all
    @klasses = Klass.where.not(name: ['Message', 'Company']).order(:name)
  end

  def show
    @role = Role.find(params[:id])
    @actions = Action.all
    @permissions = Permission.all
  end

  def create
    @role = Role.new(role_params)
    Role.transaction do
      if @role.save
        permission_params.each do |klass_id, action_ids|
          action_ids.each do |action_id, checked|
            if checked == 'true'
              RolePermission.create(role: @role, klass_id: klass_id, action_id: action_id)
            end
          end
        end
        groups_params.each do |group_id, action_ids|
          action_ids.each do |action_id, checked|
            if checked == 'true'
              RoleResource.find_or_create_by(role: @role, action_id: action_id, resource: Group.find(group_id))
            end
          end
        end
      end
    end
    redirect_to roles_path
  end

  def update
    @role = Role.find(params[:id])
    Role.transaction do
      if @role.update(role_params)
        permission_params.each do |klass_id, action_ids|
          action_ids.each do |action_id, checked|
            if checked == 'true'
              RolePermission.find_or_create_by(role: @role, klass_id: klass_id, action_id: action_id)
            else
              RolePermission.find_by(role: @role.id, klass_id: klass_id, action_id: action_id).try(:destroy)
            end
          end
        end
        groups_params.each do |group_id, action_ids|
          action_ids.each do |action_id, checked|
            if checked == 'true'
              RoleResource.find_or_create_by(role: @role, action_id: action_id, resource: Group.find(group_id))
            else
              RoleResource.find_by(role: @role, action_id: action_id, resource: Group.find(group_id)).try(:destroy)
            end
          end
        end
      end
      @role.users.each do |user|
        attrs = %w(action_id klass_id)
        permissions = @role.role_permissions.pluck(*attrs).map { |p| attrs.zip(p).to_h }
        user.user_permission.update_attributes(permissions: permissions)
      end
      flash[:notice] = 'Permission changed successfully.'
    end
    redirect_to roles_path
  end

  def destroy
    @role = Role.find(params[:id])
    if @role.any_users_exists?
      flash[:danger] = 'You cannot delete a role which is already assigned to users'
    else
      flash[:success] = 'Role deleted successfully'
      @role.destroy
    end
    redirect_to roles_path
  end

  private

  def role_params
    params.require(:role).permit(:name)
  end

  def permission_params
    params.require(:role)[:permissions]
  end

  def groups_params
    params.require(:role)[:groups]
  end

  def authorize_user!
    unless current_user.is_super_admin?
      flash[:danger] = 'You Are Not Authorized!'
      redirect_to root_path
    end
  end
end
