class AddResourcableToDirectory < ActiveRecord::Migration[5.1]
  def change
    add_reference :directories, :resourcable, polymorphic: true
    Directory.all.each do |d|
      d.resourcable_id = d.user_id
      d.resourcable_type = 'User'
      d.save
    end
    remove_reference :directories, :user 
  end
end
