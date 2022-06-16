######## Task for client and lead
klass = Klass.find_by(name: 'Task')
task_default = Group.find_or_create_by(name: "default_group", label: "Task Section", klass: klass, position: "1",hint: "", default: true)

Field.find_or_create_by(name: 'title', label: 'Title', column_type: 'Text', klass: klass, position: 1, head_position: 1, placeholder: 'Title', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: task_default)
Field.find_or_create_by(name: 'user_id', label: "Assign to", column_type: 'Picklist',  klass: klass, position: 2, head_position: 2, placeholder: "Assign to", default_value: "",  required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: task_default, deletable: false, reference: true, reference_klass: 'User', reference_key: 'first_name' )

Field.find_or_create_by(name: 'due_to', label: 'Due Date', column_type: 'DateTime', klass: klass, position: 3, head_position: 3, placeholder: 'Due Date', min_length: 0, max_length: 255, default_value: '', required: false, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: task_default)

Field.find_or_create_by(name: 'email_reminder', label: 'Email Reminder', column_type: 'DateTime', klass: klass, position: 4, head_position: 4, placeholder: 'Email Reminder', min_length: 0, max_length: 255, default_value: '', required: false, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: task_default)

Field.find_or_create_by(name: 'note', label: 'Note', column_type: 'Text Area HTML', klass: klass, position: 5, head_position: 5, placeholder: 'Note', min_length: 0, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: task_default)

field = Field.find_or_create_by(name: 'type_task', label: 'Type', column_type: 'Picklist', klass: klass, position: 6, head_position: 6, placeholder: 'Type of task', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: task_default, have_custom_value: true)
[:to_do, :email , :call ].each_with_index do |s, ind|
  field.field_picklist_values.find_or_create_by(value: s.to_s.humanize, position: ind+1)
end
Field.find_or_create_by(name: 'attachment', label: '', column_type: 'File', klass: klass, position: 7, placeholder: 'Attachment', min_length: 0, max_length: 255, required: false, quick_create: true, key_field_view: true, header_view: false, mass_edit: false, custom: false, group: task_default)
Field.find_or_create_by(name: 'get_object_name', label: 'Company Name', column_type: 'Text', klass: klass, head_position: 7, placeholder: 'Company Name', min_length: 0, max_length: 255, required: false, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false)
