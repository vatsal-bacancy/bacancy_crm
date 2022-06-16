class CreateUserFieldPreferences < ActiveRecord::Migration[5.2]
  def up
    create_table :user_field_preferences do |t|
      t.integer :position_in_table
      t.boolean :visible_in_table, default: false
      t.references :field, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end

    # We have to generate field preferences for each user from existing field
    Klass.all.each do |klass|
      position_in_table = 0
      klass.fields.each do |field|
        User.all.each do |user|
          user.field_preferences.create(position_in_table: field.header_view ? position_in_table : nil , field: field)
        end
        position_in_table += 1 if field.header_view
      end
    end
  end

  def down
    drop_table :user_field_preferences
  end
end
