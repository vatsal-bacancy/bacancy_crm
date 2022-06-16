class ChangeCategoryReferenceInDevices < ActiveRecord::Migration[5.2]
  def change
    map = {}
    Device.all.each do |device|
      map[device.category_id] = DeviceCategory.find_or_create_by(title: Category.find(device.category_id).title).id
    end

    remove_foreign_key "devices", "categories"

    map.each do |old_id, new_id|
      Device.where(category_id: old_id).update_all(category_id: new_id)
    end
    Category.where(id: map.keys).destroy_all

    add_foreign_key "devices", "device_categories", column: 'category_id'
  end
end
