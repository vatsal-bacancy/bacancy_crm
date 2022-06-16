# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
company = Company.find_or_create_by(name: "iPos")
company.update(email: "rohan@quicknetsoft.com")
directory = Directory.find_or_create_by(directoriable: company)
system_dir = Directory.create(name: 'system', directoriable: company)

super_admin = Role.find_or_create_by(name: :super_admin)
admin = Role.find_or_create_by(name: :admin)
employee = Role.find_or_create_by(name: :employee)
user = User.find_or_create_by(first_name: ENV['ADMIN_FIRST_NAME'], last_name: ENV['ADMIN_LAST_NAME'], email: ENV['ADMIN_EMAIL']) do |u|
  u.password = "password"
end
user.remove_role :employee
user.add_role :super_admin

# Create FileManager::Folder
FileManager::Folder.create!(name: 'System', owner: user)

klass_names = ["User","Lead", "Ticket", "Client", "Contact", "Company", "Project", "Invoice", "Task", "Note", "Message", "Inventory", "EmailTemplete", "Document", 'cEmail']
# ,"Calendar",  "ProjectTask", "Product"
#### Create klasses

# TODO: Rename Document to File
klass_names = {
  'User' => 'User',
  'Lead' => 'Lead Company',
  'Ticket' => 'Ticket',
  'Client' => 'Client Company',
  'Contact' => 'Contact',
  'Company' => 'Company',
  'Project' => 'Project',
  'Invoice' => 'Invoice',
  'Task' => 'Task',
  'Note' => 'Note',
  'Message' => 'Message',
  'Inventory' => 'Inventory',
  'EmailTemplete' => 'Email Template',
  'Document' => 'File Drive',
  'cEmail' => 'Email',
  'HelpDesk' => 'Help Desk Articles',
  'Vendor' => 'Vendor'
}

klass_names.each do |klass_name, klass_label|
  Klass.find_or_create_by(name: klass_name, label: klass_label)
end

# We have to persist the klasses because it `id` is used in the User.first.user_permission.permissions
klasses = Klass.all.map { |klass| klass.attributes }
Klass.destroy_all # This will destroy all the fields
klasses.each do |klass|
  Klass.create klass
end


#### Create klasses

require_relative "./seeds/seeds-user.rb"
require_relative "./seeds/seeds-lead.rb"
require_relative "./seeds/seeds-client.rb"
require_relative "./seeds/seeds-contact.rb"
require_relative "./seeds/seeds-ticket.rb"
require_relative "./seeds/seeds-task.rb"
require_relative "./seeds/seeds-project.rb"
require_relative "./seeds/seeds-invoice.rb"
require_relative "./seeds/seeds-note.rb"
require_relative "./seeds/seeds-message.rb"
require_relative "./seeds/seeds-inventory.rb"
require_relative "./seeds/seeds-email_templete.rb"
require_relative './seeds/seeds-tax.rb'
require_relative './seeds/seeds-help-desk.rb'
require_relative './seeds/seeds-vendor.rb'


### User Permissions ###
klass_names.each do |name|
  Permission.find_or_create_by(name: name)
end

Action.find_or_create_by(name: 'create')
Action.find_or_create_by(name: 'read')
Action.find_or_create_by(name: 'update')
Action.find_or_create_by(name: 'delete')
### User Permissions ###


### setting default permissions for super_user ###
super_admin_role = Role.find_by(name: :super_admin)
Klass.all.each do |klass|
  Action.all.each do |action|
    RolePermission.find_or_create_by(role: super_admin_role, klass: klass, action: action)
  end
end

#### Module numbering
  Klass.all.each do |k|
    ModuleNumber.find_or_create_by(klass_id: k.id, module_prefix: k.name.first(3).upcase , sequence_start: "1")
  end

['Stock on fire', 'Stolen goods', 'Damaged goods', 'stock written off', 'stock taking results', 'Inventory Revaluation', 'Invoice generated', 'Client inventory association'].each do |r|
  StockAdjustmentReason.find_or_create_by(reason: r)
end
