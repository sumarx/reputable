class CreatePlans < ActiveRecord::Migration[8.1]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.integer :price_cents, null: false
      t.string :currency, null: false, default: 'PKR'
      t.integer :max_locations, null: false
      t.integer :max_campaigns, null: false
      t.integer :max_reviews_per_month, null: false
      t.jsonb :features, null: false, default: '{}'
      t.boolean :active, null: false, default: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :plans, :position
    add_index :plans, :active
  end
end
