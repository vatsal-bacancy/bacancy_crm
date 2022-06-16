class ProjectManagement::Project::Task < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :assigned_to, class_name: 'User', optional: true
  belongs_to :project, class_name: 'ProjectManagement::Project'

  has_many :comments, class_name: 'ProjectManagement::Project::Task::Comment', dependent: :destroy

  def assigned_to_fullname
    assigned_to&.fullname
  end

  def set_defaults
    self.start_date = Date.current
  end

  def self.valid_statuses
    self.klass.fields.find_by(name: 'status').field_picklist_values
  end

  def self.klass
    Klass.find_by(name: klass_name)
  end

  def self.klass_name
    'ProjectManagement::Project::Task'
  end
end
