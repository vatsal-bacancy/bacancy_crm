class CreateClients < ActiveRecord::Migration[5.1]
  def change
    create_table :clients do |t|
      t.string :company_name
      t.string :lead_no
      t.string :phone_no
      t.string :company_email
      t.string :lead_status
      t.references :user, foreign_key: true
      t.text :description
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :company_url
      # t.boolean :is_admin

      t.timestamps
    end
  end
end
