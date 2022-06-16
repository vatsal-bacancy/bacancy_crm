class CreateTimeMachineVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :time_machine_versions do |t|
      t.references :original_object, polymorphic: true, index: {name: 'index_time_machine_versions_on_original_object'}
      t.string :action
      t.text :serialized_user
      t.text :serialized_object
      t.text :serialized_object_changes

      t.datetime :created_at
    end
  end
end
