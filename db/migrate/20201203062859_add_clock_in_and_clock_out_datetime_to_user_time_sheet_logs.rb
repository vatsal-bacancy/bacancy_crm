class AddClockInAndClockOutDatetimeToUserTimeSheetLogs < ActiveRecord::Migration[5.2]
  def change
    remove_column :user_time_sheet_logs, :clock_in, :time
    remove_column :user_time_sheet_logs, :clock_out, :time
    remove_column :user_time_sheet_logs, :date, :date
    add_column :user_time_sheet_logs, :clock_in_datetime, :datetime
    add_column :user_time_sheet_logs, :clock_out_datetime, :datetime
    add_column :user_time_sheet_logs, :base_date, :date

    remove_column :user_time_sheet_log_break_logs, :start_time, :time
    remove_column :user_time_sheet_log_break_logs, :end_time, :time
    add_column :user_time_sheet_log_break_logs, :start_datetime, :datetime
    add_column :user_time_sheet_log_break_logs, :end_datetime, :datetime
    add_column :users, :auto_clock_out_at, :datetime
  end
end
