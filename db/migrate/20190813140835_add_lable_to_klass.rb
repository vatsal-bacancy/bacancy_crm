class AddLableToKlass < ActiveRecord::Migration[5.1]
  def change
    add_column :klasses, :label, :string
  end
end
