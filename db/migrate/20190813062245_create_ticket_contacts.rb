class CreateTicketContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :ticket_contacts do |t|
      t.references :contact, foreign_key: true
      t.references :ticket, foreign_key: true

      t.timestamps
    end
  end
end
