class CreateUserTimeSheetLogEmailSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_time_sheet_log_email_settings do |t|
      t.string :recipients, array: true
      t.integer :days_range
      t.string :recurrence_schedule

      t.timestamps
    end
  end
end
