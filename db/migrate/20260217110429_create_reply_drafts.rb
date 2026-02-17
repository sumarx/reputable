class CreateReplyDrafts < ActiveRecord::Migration[8.1]
  def change
    create_table :reply_drafts do |t|
      t.references :review, null: false, foreign_key: true
      t.text :body, null: false
      t.string :tone, default: "professional"
      t.string :status, default: "draft"

      t.timestamps
    end
  end
end
