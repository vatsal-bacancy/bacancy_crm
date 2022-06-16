class AddAncestryToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :ancestry, :string
    add_index :groups, :ancestry
  end
end
