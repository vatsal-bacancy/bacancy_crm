class WorkFlows::WorkFlowWorker
  include Sidekiq::Worker

  def perform(work_flow_id)
    work_flow = WorkFlows::WorkFlow.find(work_flow_id)
    work_flow.klass.constant.all.find_each do |object|
      work_flow.execute(object)
    end
  end
end
