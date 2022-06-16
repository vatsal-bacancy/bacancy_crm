class ProjectAssigneeMailer < ApplicationMailer
  default from: ENV['FROM_EMAIL']

  def send_project_invitation(project_assignee)
    @project_assignee = project_assignee
    @project_owner = project_assignee.project.user
    mail to: project_assignee.email, subject: "#{project_assignee.project.user.fullname} added you to a project in iPos CRM"
  end

end
