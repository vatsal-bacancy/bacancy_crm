class PasswordsController < Devise::PasswordsController

	def edit
		super
		# if(params[:project_user].present?)
    #   @project_user = ProjectUser.find(params[:project_user])
    #   if @project_user.present?
    #     @project_user.update(status: true)
    #   end
    # end
		@invitation = params[:invitation]
	end

  def update
    super
    if resource.errors.empty?
			if params[:invitation].present?
      	resource.update(first_name: params[:user][:first_name], last_name: params[:user][:last_name])
			end
		end
  end

end
