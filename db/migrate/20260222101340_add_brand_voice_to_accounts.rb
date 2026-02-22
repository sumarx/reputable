class AddBrandVoiceToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :brand_description, :text
    add_column :accounts, :brand_reply_guidelines, :text
    add_column :accounts, :brand_always_mention, :text
    add_column :accounts, :brand_never_say, :text
    add_column :accounts, :brand_sample_replies, :text
  end
end
