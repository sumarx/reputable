class AddSlackToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :notify_slack, :boolean, default: false
    add_column :accounts, :slack_webhook_url, :string
  end
end
