class AddProfilePictureToContact < ActiveRecord::Migration[5.1]
  def change
    add_column :contacts, :profile_picture, :string
  end
end
