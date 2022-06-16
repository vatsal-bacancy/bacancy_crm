class AddDeletedAtToModel < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :deleted_at, :datetime
    add_column :leads, :deleted_at, :datetime
    add_column :tasks, :deleted_at, :datetime
    add_column :projects, :deleted_at, :datetime
    add_column :notes, :deleted_at, :datetime
    add_column :comments, :deleted_at, :datetime
    add_column :directories, :deleted_at, :datetime
    add_column :documents, :deleted_at, :datetime
    add_column :fields, :deleted_at, :datetime
    add_column :groups, :deleted_at, :datetime
    add_column :invoices, :deleted_at, :datetime
    add_column :tickets, :deleted_at, :datetime
    add_column :users, :deleted_at, :datetime


    add_index :clients, :deleted_at
    add_index :leads, :deleted_at
    add_index :tasks, :deleted_at
    add_index :projects, :deleted_at
    add_index :notes, :deleted_at
    add_index :comments, :deleted_at
    add_index :directories, :deleted_at
    add_index :documents, :deleted_at
    add_index :fields, :deleted_at
    add_index :groups, :deleted_at
    add_index :invoices, :deleted_at
    add_index :tickets, :deleted_at
    add_index :users, :deleted_at

  end
end
