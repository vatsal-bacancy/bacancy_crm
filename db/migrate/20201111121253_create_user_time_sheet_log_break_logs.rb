class CreateUserTimeSheetLogBreakLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :user_time_sheet_log_break_logs do |t|
      t.references :time_sheet_log, foreign_key: { to_table: 'user_time_sheet_logs' }
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
  end
end
