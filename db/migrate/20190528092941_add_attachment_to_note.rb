class AddAttachmentToNote < ActiveRecord::Migration[5.1]
  def change
    add_column :notes, :attachment, :string
  end
end
