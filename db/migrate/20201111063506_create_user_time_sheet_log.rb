class CreateUserTimeSheetLog < ActiveRecord::Migration[5.2]
  def change
    create_table :user_time_sheet_logs do |t|
      t.references :user, foreign_key: true
      t.date :date
      t.time :clock_in
      t.time :clock_out

      t.timestamps
    end
  end
end
