class CreateUnits < ActiveRecord::Migration[5.1]
  def change
    create_table :units do |t|
      t.string :messure

      t.timestamps
    end
    %w[box cm dz ft g in kg km lb mg m pcs].each{ |messure| Unit.create(messure: messure)}
  end
end
