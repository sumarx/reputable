class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :address
      t.string :city
      t.string :country
      t.string :phone
      t.string :google_place_id
      t.string :facebook_page_id
      t.string :tripadvisor_id
      t.float :latitude
      t.float :longitude
      t.float :average_rating
      t.integer :total_reviews, default: 0

      t.timestamps
    end
  end
end
