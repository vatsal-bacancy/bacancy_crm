class WorkFlowsController < ApplicationController
  before_action :authenticate_user!

  def index
    @work_flows = WorkFlows::WorkFlow.all
  end

  def new
    @work_flow = WorkFlows::WorkFlow.new
  end

  def edit
    @work_flow = WorkFlows::WorkFlow.find(params[:id])
  end

  def create
    work_flow = WorkFlows::WorkFlow.new(work_flow_params)
    if work_flow.save
      flash[:success] = 'Work Flow created successfully'
    else
      flash[:danger] = 'Something went wrong while creating Work Flow'
    end
    redirect_to work_flows_path
  end

  def update
    work_flow = WorkFlows::WorkFlow.find(params[:id])
    if work_flow.update(work_flow_params)
      flash[:success] = 'Work Flow updated successfully'
    else
      flash[:danger] = 'Something went wrong while updating Work Flow'
    end
    redirect_to edit_work_flow_path
  end

  def destroy
    work_flow = WorkFlows::WorkFlow.find(params[:id])
    if work_flow.destroy
      flash[:success] = 'Work Flow destroyed successfully'
    else
      flash[:danger] = 'Something went wrong while destroying Work Flow'
    end
    redirect_to work_flows_path
  end

  # for form builder pattern
  def builder
    @work_flow = WorkFlows::WorkFlow.new(work_flow_params)
    @work_flow.and_conditions = []
    @work_flow.or_conditions = []
  end

  # for work flow action modal builder (STI)
  #   TODO: rather than passing `type` and building the action like `actions.build`,
  #           we can use the action which is built by `nested attributes`
  def action_builder
    work_flow = WorkFlows::WorkFlow.new(work_flow_params)
    @action = work_flow.actions.build(type: params[:type])
  end

  private

  def work_flow_params
    params.require(:work_flow).permit(:name, :description, :klass_id, :on, :recurrence_schedule, and_conditions_attributes: {}, or_conditions_attributes: {}, actions_attributes: {})
  end
end
