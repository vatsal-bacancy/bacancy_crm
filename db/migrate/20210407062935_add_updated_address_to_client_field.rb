class AddUpdatedAddressToClientField < ActiveRecord::Migration[5.2]
  def change
    add_column :client_fields, :updated_address, :string, default: ''
  end
end
