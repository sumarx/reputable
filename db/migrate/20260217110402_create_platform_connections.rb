class CreatePlatformConnections < ActiveRecord::Migration[8.1]
  def change
    create_table :platform_connections do |t|
      t.references :location, null: false, foreign_key: true
      t.string :platform, null: false
      t.string :external_id
      t.string :access_token_ciphertext
      t.string :refresh_token_ciphertext
      t.datetime :token_expires_at
      t.string :status, default: "active"
      t.datetime :last_synced_at

      t.timestamps
    end
    add_index :platform_connections, [:location_id, :platform], unique: true
  end
end
