class CreatePurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_order_devices do |t|
      t.string :name
      t.string :description
      t.string :category
      t.integer :order
      t.timestamps
    end

    create_table :purchase_order_products do |t|
      t.string :name
      t.integer :price
      t.boolean :available
      t.integer :product_type
      t.timestamps
    end

    create_table :purchase_order_device_products do |t|
      t.references :device, foreign_key: { to_table: :purchase_order_devices }
      t.references :product, foreign_key: { to_table: :purchase_order_products }
      t.timestamps
    end

    create_table :purchase_order_versions do |t|
      t.references :purchase_orderable, polymorphic: true, index: { name: 'index_purchase_orderable' }
      t.references :created_by, foreign_key: { to_table: :users }
      t.string :serialized_devices
      t.string :notes
      t.integer :financed_payment_year_plan
      t.float :financed_hardware_total
      t.float :financed_software_total
      t.float :financed_promotional_discount
      t.float :financed_due_from_agent
      t.float :financed_total
      t.float :financed_monthly_total
      t.float :upfront_hardware_total
      t.float :upfront_promotional_discount
      t.float :upfront_due_from_agent
      t.float :upfront_total
      t.timestamps
    end
  end
end
