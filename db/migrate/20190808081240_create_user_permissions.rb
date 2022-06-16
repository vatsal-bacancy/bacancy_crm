class CreateUserPermissions < ActiveRecord::Migration[5.1]
  def change
    create_table :user_permissions do |t|
      t.references :user, foreign_key: true
      t.jsonb :permissions

      t.timestamps
    end
  end
end
