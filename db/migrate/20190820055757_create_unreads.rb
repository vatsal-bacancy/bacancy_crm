class CreateUnreads < ActiveRecord::Migration[5.1]
  def change
    create_table :unreads do |t|
      t.references :unreadable, polymorphic: true
      t.references :resourcable, polymorphic: true

      t.timestamps
    end
  end
end
