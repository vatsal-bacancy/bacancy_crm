class AddRecurrenceScheduleToWorkFlows < ActiveRecord::Migration[5.2]
  def change
    add_column :work_flows_work_flows, :recurrence_schedule, :string
  end
end
