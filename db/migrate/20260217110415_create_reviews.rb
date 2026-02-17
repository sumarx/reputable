class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :location, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :platform, null: false
      t.string :external_review_id, null: false
      t.string :reviewer_name
      t.string :reviewer_avatar_url
      t.integer :rating
      t.text :body
      t.text :reply
      t.datetime :replied_at
      t.string :reply_status, default: "pending"
      t.string :sentiment
      t.float :sentiment_score
      t.jsonb :categories, default: []
      t.jsonb :metadata, default: {}
      t.datetime :published_at

      t.timestamps
    end
    
    add_index :reviews, [:account_id, :platform, :external_review_id], unique: true, name: 'index_reviews_unique_external'
    add_index :reviews, [:account_id, :sentiment]
    add_index :reviews, [:account_id, :published_at]
    add_index :reviews, :categories, using: :gin
  end
end
