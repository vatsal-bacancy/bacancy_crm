class CreateRoleResources < ActiveRecord::Migration[5.1]
  def change
    create_table :role_resources do |t|
      t.references :role, foreign_key: true
      t.references :action, foreign_key: true
      t.references :resource, polymorphic: true

      t.timestamps
    end
  end
end
