class ProjectDocument < ApplicationRecord
  belongs_to :project
  # belongs_to :user
  belongs_to :resourcable, polymorphic: true
  belongs_to :message
  mount_uploader :attachment, DocumentUploader
end
