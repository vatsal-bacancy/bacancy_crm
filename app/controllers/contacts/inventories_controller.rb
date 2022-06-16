class Contacts::InventoriesController < ApplicationController
  layout 'contacts'

  def index
    @inventories = Inventory.joins('INNER JOIN invoice_inventories ON invoice_inventories.inventory_id = inventories.id INNER JOIN invoices ON invoice_inventories.invoice_id = invoices.id INNER JOIN clients ON invoices.client_id = clients.id INNER JOIN lead_client_contacts on lead_client_contacts.contactable_id = clients.id INNER JOIN contacts ON lead_client_contacts.contact_id = contacts.id INNER JOIN payments ON payments.invoice_id = invoices.id').where("lead_client_contacts.contactable_type = 'Client' AND contacts.id = (?) AND payments.successful = (?)", current_contact.id, true).uniq
  end

end
# lead_client_contact
# Inventory.joins('INNER JOIN invoice_inventories ON invoice_inventories.inventory_id = inventories.id INNER JOIN invoices ON invoice_inventories.invoice_id = invoices.id INNER JOIN clients ON invoices.client_id = clients.id INNER JOIN lead_client_contacts on lead_client_contacts.contactable_id = clients.id INNER JOIN contacts ON lead_client_contacts.contact_id = contacts.id').where("lead_client_contacts.contactable_type = 'Client' AND contacts.id = (?) ", current_contact.id)
