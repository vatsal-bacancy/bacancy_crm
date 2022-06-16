class ProjectAssignee < ApplicationRecord
  belongs_to :project
  belongs_to :user, optional: true

  before_save :set_user
  after_create :send_invitation

  private

  def set_user
    return if user.present?
    self.user = User.find_by(email: email)
  end

  def send_invitation
    ProjectAssigneeWorker.perform_async(id)
  end
end
