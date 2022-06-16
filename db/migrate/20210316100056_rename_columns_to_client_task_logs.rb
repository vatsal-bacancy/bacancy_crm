class RenameColumnsToClientTaskLogs < ActiveRecord::Migration[5.2]
  def change
    rename_column :client_task_logs, :app_checkin, :user_checkin_timestamp
    rename_column :client_task_logs, :app_checkout, :user_checkout_timestamp
  end
end
