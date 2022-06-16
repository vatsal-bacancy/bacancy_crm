class AddAttachmentToTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :attachment, :string
  end
end
