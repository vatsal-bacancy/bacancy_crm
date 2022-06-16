class InvitationMailer < ApplicationMailer

	# if user already present (send login email)
	def user_login_instructions(opts)
		@user = User.find(opts[:user_id])
		@current_user = User.find(opts[:current_user_id])
		mail to: @user.email, subject: "#{@current_user.fullname} has invited you to join them in iPos CRM"
	end

	# if user not present (send signup email to set password)
	def user_account_setup_instructions(opts)
		@user = User.find(opts[:user_id])
		@current_user = User.find(opts[:current_user_id])
		@token = opts[:token]
		@client = Client.find(opts[:client_id]) if opts[:client_id]
		mail(to: @user.email, subject: "#{@current_user.fullname} has invited you to join them in iPos CRM")
	end

	# if contact already present (send login email)
	def contact_login_instructions(opts)
		@contact = Contact.find(opts[:contact_id])
		@current_user = User.find(opts[:current_user_id])
		mail to: @contact.email, subject: "#{@current_user.fullname} has invited you to join them in iPos CRM"
	end

	# if contact not present (send signup email to set password)
	def contact_account_setup_instructions(opts)
		@contact = Contact.find(opts[:contact_id])
		@current_user = User.find(opts[:current_user_id])
		@token = opts[:token]
		mail(to: @contact.email, subject: "#{@current_user.fullname} has invited you to join them in iPos CRM")
	end

	#send project invitation to contact
	def project_contact_invitation(opts={})
    @user = User.find(opts['current_user'])
    @contact = Contact.find(opts['contact_id'])
    @project = Project.find(opts['project_id'])
    @project_contact = ProjectContact.find(opts['project_contact_id'])

    mail to: @contact.email, subject: "#{@user.fullname} has invited you to join them in #{@project.try(:name)} project"
	end

	#send project invitation to user
	def project_user_invitation(opts={})
		@current_user = User.find(opts['current_user'])
    @user = User.find(opts['user_id'])
    @project = Project.find(opts['project_id'])
    @project_user = ProjectUser.find(opts['project_user_id'])
		@status = opts['login_status']
		@token = opts['token']
    mail to: @user.email, subject: "#{@current_user.fullname} has invited you to join them in #{@project.try(:name)} project"
	end
end
