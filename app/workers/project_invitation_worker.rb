class ProjectInvitationWorker
  include Sidekiq::Worker

  def perform(id, current_user_id, user, project, project_user, status, token)
  	# project_invitation
    ProjectInvitationMailer.project_invitation_mail( User.find(current_user_id), user: User.find(user), project: Project.find(project), project_user: ProjectUser.find(project_user), login_status: status, token: token).deliver
  end
end
