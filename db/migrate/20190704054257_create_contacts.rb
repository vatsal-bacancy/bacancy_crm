class CreateContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_no
      t.boolean :portal_invitation
      t.boolean :is_primary
      t.timestamps
    end
  end
end
