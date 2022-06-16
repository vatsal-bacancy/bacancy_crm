class ChangeDefaultIsbn < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:inventories, :isbn, nil)
  end
end
