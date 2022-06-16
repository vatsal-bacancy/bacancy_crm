class ProjectManagement::Project < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :client

  has_many :tasks, class_name: 'ProjectManagement::Project::Task', dependent: :destroy

  has_many :resources, class_name: 'ProjectManagement::Project::Resource', dependent: :destroy
  has_many :user_resources, -> { where(resourceable_type: 'User') }, class_name: 'ProjectManagement::Project::Resource'
  has_many :users, through: :resources, source: :resourceable, source_type: 'User'
  has_many :contact_resources, -> { where(resourceable_type: 'Contact') }, class_name: 'ProjectManagement::Project::Resource'
  has_many :contacts, through: :resources, source: :resourceable, source_type: 'Contact'

  accepts_nested_attributes_for :resources, allow_destroy: true

  def set_defaults
    self.start_date = Date.current
  end

  def self.klass
    Klass.find_by(name: klass_name)
  end

  def self.klass_name
    'ProjectManagement::Project'
  end
end
