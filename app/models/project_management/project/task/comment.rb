class ProjectManagement::Project::Task::Comment < ApplicationRecord
  belongs_to :task, class_name: 'ProjectManagement::Project::Task'
  belongs_to :created_by, class_name: 'User'
end
