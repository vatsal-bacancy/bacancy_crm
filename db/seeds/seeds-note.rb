
############## Note for Lead and Client
klass = Klass.find_by(name: 'Note')
note_default = Group.find_or_create_by(name: "default_group", label: "Note Details", klass: klass, position: "1",hint: "", default: true)

Field.find_or_create_by(name: 'content', label: 'Note', column_type: 'Text Area HTML', klass: klass, position: 1, head_position: 1, placeholder: 'Title', min_length: 0, max_length: 255, default_value: '', required: true, quick_create: true, key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false, group: note_default)

Field.find_or_create_by(name: 'attachment', label: '', column_type: 'File', klass: klass, position: 2, placeholder: 'Attachment', min_length: 0, max_length: 255, required: false, quick_create: true, key_field_view: true, header_view: false, mass_edit: false, custom: false, group: note_default)

Field.find_or_create_by(name: 'created_at', label: 'Created At', column_type: 'DateTime', klass: klass, head_position: 2, placeholder: 'Created At', min_length: 0, max_length: 255, default_value: '', key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false )

Field.find_or_create_by(name: 'user_id', label: 'Created by', column_type: 'Picklist', klass: klass, head_position: 3, placeholder: 'Created by', min_length: 0, max_length: 255, default_value: '', key_field_view: true, header_view: true, mass_edit: false, system_field: true, custom: false )
