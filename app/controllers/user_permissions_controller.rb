class UserPermissionsController < ApplicationController

  def edit
    @user = User.find(params[:id])
    @user_permission = @user.user_permission
    @actions = Action.all
    @klasses = Klass.where.not(name: ['Message', 'Company']).order(:label)
  end

  def update
    @user_permission = UserPermission.find(params[:id])
    permissions = []
    if params[:user_permission].present?
      params[:user_permission][:permissions].each do |klass_id, val|
        val.keys.each do |action_id|
          permissions << {klass_id: klass_id.to_i, action_id: action_id.to_i}
        end
      end
    end
    @user_permission.update(permissions: permissions)
    flash[:notice] = "User permission updated successfully."
    redirect_to users_path
  end
end
