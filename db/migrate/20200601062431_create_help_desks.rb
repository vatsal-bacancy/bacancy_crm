class CreateHelpDesks < ActiveRecord::Migration[5.2]
  def change
    create_table :help_desks do |t|
      t.string :category
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
