class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.references :invoice, foreign_key: true
      t.boolean :successful, default: false
      t.binary :response

      t.timestamps
    end
  end
end
