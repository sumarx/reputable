class CreateCampaignResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :campaign_responses do |t|
      t.references :campaign, null: false, foreign_key: true
      t.integer :rating
      t.text :feedback
      t.string :outcome
      t.string :customer_name
      t.string :customer_phone

      t.timestamps
    end
  end
end
