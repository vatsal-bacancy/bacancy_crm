class CreateContractContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :contract_contracts do |t|
      t.string :title
      t.text :description
      t.references :contractable, polymorphic: true, index: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
