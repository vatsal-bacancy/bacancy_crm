class CreateAttributeOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :attribute_options do |t|
      t.string :option_name

      t.timestamps
    end
    %w[size color].each{|attribute| AttributeOption.create(option_name: attribute)}
  end
end
