class ProjectTask < ApplicationRecord
  # acts_as_paranoid
  audited
  belongs_to :assigned_by, class_name: 'User'
  belongs_to :assigned_to, class_name: 'User'
  belongs_to :project

  def related_to_task
    #getter method
    project.try(:name)
  end

  def related_to_task=(name)
    #setter method
    self.project_id = Project.find_by(name: name).id
  end
end
