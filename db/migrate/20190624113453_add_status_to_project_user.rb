class AddStatusToProjectUser < ActiveRecord::Migration[5.1]
  def change
    add_column :project_users, :status, :boolean
  end
end
