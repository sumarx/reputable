class AddGoogleOauthToLocations < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :google_oauth_token_ciphertext, :text
    add_column :locations, :google_oauth_refresh_token_ciphertext, :text
    add_column :locations, :google_oauth_expires_at, :datetime
    add_column :locations, :google_account_id, :string
    add_column :locations, :google_location_id, :string
    add_column :locations, :google_connected, :boolean, default: false
  end
end
