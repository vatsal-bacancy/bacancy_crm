module WorkFlows::Observer
  extend ActiveSupport::Concern

  included do
    after_create do
      WorkFlows::WorkFlow.where(on: :created, klass: Klass.find_by(name: self.class.name)).each do |work_flow|
        work_flow.execute(self)
      end
    end

    # after_save instead of after_update because workflow's update should include creation also.
    after_save do
      WorkFlows::WorkFlow.where(on: :updated, klass: Klass.find_by(name: self.class.name)).each do |work_flow|
        work_flow.execute(self)
      end
    end

    after_destroy do
      WorkFlows::WorkFlow.where(on: :deleted, klass: Klass.find_by(name: self.class.name)).each do |work_flow|
        work_flow.execute(self)
      end
    end
  end
end
