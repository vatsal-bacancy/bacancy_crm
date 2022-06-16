class AddOtpToEmployee < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :feedback_otp, :string, default: ''
  end
end
