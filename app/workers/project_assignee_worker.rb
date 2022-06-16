class ProjectAssigneeWorker
  include Sidekiq::Worker

  def perform(project_assignee_id)
    project_assignee = ProjectAssignee.find(project_assignee_id)
    ProjectAssigneeMailer.send_project_invitation(project_assignee).deliver
  end
end
