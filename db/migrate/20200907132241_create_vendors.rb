class CreateVendors < ActiveRecord::Migration[5.2]
  def change
    create_table :vendors do |t|
      t.string :company_name
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :website_url
      t.text :description
      t.references :assigned_to, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
