# We are using STI, for multi-purpose
class WorkFlows::Action < ApplicationRecord
  belongs_to :work_flow

  def valid_groups
    self.work_flow.klass.groups
  end

  def execute(object)
    raise NotImplementedError
  end

  def self.mail_type
    'WorkFlows::Action::Mail'
  end

  def self.sms_type
    'WorkFlows::Action::SMS'
  end

  def self.mail_type?
    self == WorkFlows::Action::Mail
  end

  def self.sms_type?
    self == WorkFlows::Action::SMS
  end

  # To solve routing related problems
  def self.model_name
    ActiveModel::Name.new("WorkFlow::Action", nil, "Action")
  end
end
