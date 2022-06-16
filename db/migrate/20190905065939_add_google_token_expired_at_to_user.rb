class AddGoogleTokenExpiredAtToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :google_token_expired_at, :datetime
  end
end
