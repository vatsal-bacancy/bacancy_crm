class RemoveHardwareAndSoftwareFromDeviceLists < ActiveRecord::Migration[5.2]
  def change
    remove_column :device_lists, :hardware, :float
    remove_column :device_lists, :software, :float
  end
end
