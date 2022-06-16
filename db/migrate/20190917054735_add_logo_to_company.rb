class AddLogoToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :big_logo, :string
    add_column :companies, :small_logo, :string
    add_column :companies, :fevicon_logo, :string
    add_column :companies, :description, :string
  end
end
