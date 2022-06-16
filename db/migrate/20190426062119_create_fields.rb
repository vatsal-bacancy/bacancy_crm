class CreateFields < ActiveRecord::Migration[5.1]
  def change
    create_table :fields do |t|
      t.string :name
      t.string :label
      t.string :column_type
      t.references :klass, foreign_key: true
      t.integer :position
      t.integer :head_position
      t.string :placeholder
      t.integer :min_length
      t.integer :max_length
      t.string :default_value
      t.boolean :required, default: false
      t.boolean :quick_create, default: false
      t.boolean :key_field_view, default: false
      t.boolean :header_view, default: false
      t.boolean :mass_edit, default: false
      t.boolean :deletable, default: true
      t.boolean :system_field, default: false
      t.references :group, foreign_key: true
      t.boolean :custom, default: true
      t.boolean :reference, default: false
      t.string :reference_klass, default: ''
      t.string :reference_key, default: ''
      t.timestamps
    end
  end
end
