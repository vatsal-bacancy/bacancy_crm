class AddColumnsToClientTaskLog < ActiveRecord::Migration[5.2]
  def change
    rename_column :client_task_logs, :location_latitude, :checkin_latitude
    rename_column :client_task_logs, :location_longitude, :checkin_longitude

    add_column :client_task_logs, :checkout_latitude, :string, default: ''
    add_column :client_task_logs, :checkout_longitude, :string, default: ''
  end
end
