class AddFieldsToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :domain_url, :string
    add_column :companies, :email, :string
    add_column :companies, :street_address, :string
    add_column :companies, :city, :string
    add_column :companies, :state, :string
    add_column :companies, :zip_code, :string
    add_column :companies, :work_phone, :string
    add_column :companies, :website_url, :string
  end
end
