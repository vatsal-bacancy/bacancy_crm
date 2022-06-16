klass = Klass.create!(name: 'Meetings::Meeting', label: 'Meeting')
group = Group.create!(name: 'Meeting Information', label: 'Meeting Information', klass: klass, position: 1, default: true)

Field.create!(name: 'title', label: 'Meeting Title', column_type: 'Text', klass: klass, position: 1, placeholder: 'Meeting Title', min_length: nil, max_length: nil, default_value: nil, required: true, quick_create: true, key_field_view: false, mass_edit: false, deletable: false, system_field: true, group: group, custom: false, reference: false, reference_klass: nil, reference_key: nil, have_custom_value: false)
Field.create!(name: 'description', label: 'Description', column_type: 'Text Area HTML', klass: klass, position: 2, placeholder: 'Description', min_length: nil, max_length: nil, default_value: nil, required: false, quick_create: true, key_field_view: false, mass_edit: false, deletable: false, system_field: true, group: group, custom: false, reference: false, reference_klass: nil, reference_key: nil, have_custom_value: false)
Field.create!(name: 'date', label: 'Meeting Date', column_type: 'Date', klass: klass, position: 3, placeholder: 'Meeting Date', min_length: nil, max_length: nil, default_value: nil, required: true, quick_create: true, key_field_view: false, mass_edit: false, deletable: false, system_field: true, group: group, custom: false, reference: false, reference_klass: nil, reference_key: nil, have_custom_value: false)
Field.create!(name: 'start_time', label: 'Start Time', column_type: 'Time', klass: klass, position: 4, placeholder: 'Start Time', min_length: nil, max_length: nil, default_value: nil, required: true, quick_create: true, key_field_view: false, mass_edit: false, deletable: false, system_field: true, group: group, custom: false, reference: false, reference_klass: nil, reference_key: nil, have_custom_value: false)
Field.create!(name: 'end_time', label: 'End Time', column_type: 'Time', klass: klass, position: 5, placeholder: 'End Time', min_length: nil, max_length: nil, default_value: nil, required: true, quick_create: true, key_field_view: false, mass_edit: false, deletable: false, system_field: true, group: group, custom: false, reference: false, reference_klass: nil, reference_key: nil, have_custom_value: false)
