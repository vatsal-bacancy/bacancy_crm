class CreateClientShipments < ActiveRecord::Migration[5.2]
  def change
    create_table :client_shipments do |t|
      t.references :client, foreign_key: true

      t.string :shipper_person_name
      t.string :shipper_person_phone_no
      t.string :shipper_street_line
      t.string :shipper_city
      t.string :shipper_state
      t.string :shipper_country
      t.string :shipper_zip_code

      t.string :recipient_person_name
      t.string :recipient_person_phone_no
      t.string :recipient_street_line
      t.string :recipient_city
      t.string :recipient_state
      t.string :recipient_country
      t.string :recipient_zip_code

      t.datetime :ship_date
      t.string :service_type
      t.string :package_type

      t.string :payment_type

      t.string :drop_off_type

      t.timestamps
    end

    create_table :client_shipment_packages do |t|
      t.references :shipment, foreign_key: { to_table: 'client_shipments' }

      t.float :weight
      t.string :description

      t.string :tracking_number
      t.binary :raw_response

      t.timestamps
    end
  end
end
