class CreateEmployees < ActiveRecord::Migration[5.2]
  def change
    create_table :employees do |t|
      t.string :full_name, default: ''
      t.string :country_code, default: ''
      t.string :phone_number, default: ''
      t.references :client, foreign_key: true
      t.boolean :feedback_submitted, default: false
      t.boolean :retraining, default: false
      t.timestamps
    end
  end
end
