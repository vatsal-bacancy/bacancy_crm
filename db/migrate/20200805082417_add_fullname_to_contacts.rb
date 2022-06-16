class AddFullnameToContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :fullname, :string
  end
end
