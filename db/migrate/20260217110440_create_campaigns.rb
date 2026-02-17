class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.references :location, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :campaign_type, default: "qr"
      t.string :slug, null: false
      t.integer :positive_threshold, default: 4
      t.string :redirect_platform, default: "google"
      t.boolean :active, default: true
      t.integer :responses_count, default: 0
      t.integer :redirects_count, default: 0

      t.timestamps
    end
    add_index :campaigns, :slug, unique: true
  end
end
