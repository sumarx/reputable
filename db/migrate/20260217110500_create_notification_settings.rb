class CreateNotificationSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :email_on_negative, default: true
      t.boolean :email_daily_digest, default: true
      t.boolean :sms_on_negative, default: false
      t.boolean :slack_webhook_enabled, default: false
      t.string :slack_webhook_url
      t.string :phone_number

      t.timestamps
    end
  end
end
