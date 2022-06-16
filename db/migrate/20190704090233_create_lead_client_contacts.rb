class CreateLeadClientContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :lead_client_contacts do |t|
      t.references :contact, foreign_key: true
      t.references :contactable, polymorphic: true, index: false

      t.timestamps
    end
    add_index :lead_client_contacts,["contactable_type", "contactable_id"], :name => 'lead_client_contactable_index'
  end
end
