class WorkFlows::WorkFlow < ApplicationRecord
  belongs_to :klass
  has_many :and_conditions, class_name: 'WorkFlows::AndCondition', dependent: :destroy
  has_many :or_conditions, class_name: 'WorkFlows::OrCondition', dependent: :destroy
  has_many :actions, class_name: 'WorkFlows::Action', dependent: :destroy

  accepts_nested_attributes_for :and_conditions, allow_destroy: true
  accepts_nested_attributes_for :or_conditions, allow_destroy: true
  accepts_nested_attributes_for :actions, allow_destroy: true

  enum on: [:created, :updated, :deleted, :recurrence]

  def execute(object)
    and_conditions_eval = and_conditions.map do |condition|
      condition.execute(object)
    end
    or_conditions_eval = or_conditions.map do |condition|
      condition.execute(object)
    end
    and_conditions_eval.push(true) if and_conditions_eval.empty?
    or_conditions_eval.push(true) if or_conditions_eval.empty?
    condition = and_conditions_eval.all? && or_conditions_eval.any?
    actions.each do |action|
      action.execute(object)
    end if condition
  end

  after_save do
    destroy_recurrence_job
    create_recurrence_job if recurrence?
  end

  after_destroy do
    destroy_recurrence_job
  end

  # To solve routing related problems
  def self.model_name
    ActiveModel::Name.new("WorkFlow::WorkFlow", nil, "WorkFlow")
  end

  private

  def create_recurrence_job
    Sidekiq::Cron::Job.create(name: self.to_gid_param, cron: recurrence_schedule, class: 'WorkFlows::WorkFlowWorker', args: [id])
  end

  def destroy_recurrence_job
    Sidekiq::Cron::Job.destroy(self.to_gid_param)
  end
end
