# seed file for message module
klass = Klass.find_by(name: 'Message')
message_default = Group.find_or_create_by(name: "default_group", label: "Message Details", klass: klass, position: "1",hint: "", default: true)

Field.find_or_create_by(name: 'title', label: 'Title', column_type: 'Text', klass: klass, position: 1, head_position: 1, placeholder: 'Title', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: message_default)
category_value = Field.find_or_create_by(name: 'category', label: "Category", column_type: 'Picklist', klass: klass, position: 2, head_position: 2, placeholder: "Category", default_value: "", required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: message_default, have_custom_value: true)
[:test_message_IV].each_with_index do |s, ind|
	category_value.field_picklist_values.find_or_create_by(value: s.to_s.humanize, position: ind+1)
end

priority_value = Field.find_or_create_by(name: 'priority', label: "Priority", column_type: 'Picklist', klass: klass, position: 3, head_position: 3, placeholder: "Priority", default_value: "", required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: message_default, have_custom_value: true)
[:normal, :medium, :high, :low].each_with_index do |s, ind|
	priority_value.field_picklist_values.find_or_create_by(value: s.to_s.humanize, position: ind+1)
end

status_value = Field.find_or_create_by(name: 'status', label: "Status", column_type: 'Picklist', klass: klass, position: 4, head_position: 4, placeholder: "Status", default_value: "", required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: message_default, have_custom_value: true)
[:to_do, :in_progress, :completed, :on_hold, :cancelled].each_with_index do |s, ind|
	status_value.field_picklist_values.find_or_create_by(value: s.to_s.humanize, position: ind+1)
end

Field.find_or_create_by(name: 'description', label: "Description", column_type: 'Text Area HTML', klass: klass, position: 5, head_position: 5, placeholder: "Description", min_length: 0, default_value: "", required: false, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, custom: false, group: message_default)
# Field.find_or_create_by(name: 'user_id', column_type: 'Hidden',  klass: klass, deletable: false, reference: true, reference_klass: 'user', reference_key: 'first_name', group: message_default)
