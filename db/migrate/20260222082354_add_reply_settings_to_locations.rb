class AddReplySettingsToLocations < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :auto_generate_replies, :boolean, default: true, null: false
    add_column :locations, :default_reply_tone, :string, default: "professional", null: false
    add_column :locations, :auto_post_replies, :boolean, default: false, null: false
  end
end
