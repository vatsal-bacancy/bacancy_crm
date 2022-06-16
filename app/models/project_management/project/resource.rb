class ProjectManagement::Project::Resource < ApplicationRecord
  belongs_to :resourceable, polymorphic: true
  belongs_to :project, class_name: 'ProjectManagement::Project'
end
