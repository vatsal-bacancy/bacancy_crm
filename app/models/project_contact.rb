class ProjectContact < ApplicationRecord
  belongs_to :project
  belongs_to :contact
  belongs_to :client, optional: true

  after_create :create_unread

  def create_unread
    Unread.create(unreadable: project, resourcable: contact)
  end
end
