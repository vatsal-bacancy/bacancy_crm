class CreateContractTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :contract_templates do |t|
      t.string :name
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
