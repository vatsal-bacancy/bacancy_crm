class AddTwoFactorFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :direct_otp, :string
  end
end
