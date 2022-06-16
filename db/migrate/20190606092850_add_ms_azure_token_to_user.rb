class AddMsAzureTokenToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :ms_azure_token, :jsonb
  end
end
