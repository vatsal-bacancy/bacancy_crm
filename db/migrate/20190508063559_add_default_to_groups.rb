class AddDefaultToGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :groups, :default, :boolean, default: false
  end
end
