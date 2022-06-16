class CreateUserTfaPhoneNumbers < ActiveRecord::Migration[5.2]
  def change
    create_table :user_tfa_phone_numbers do |t|
      t.string :number

      t.timestamps
    end
  end
end
