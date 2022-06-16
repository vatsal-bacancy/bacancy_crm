class CreateDeviceCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :device_categories do |t|
      t.string :title

      t.timestamps
    end
  end
end
