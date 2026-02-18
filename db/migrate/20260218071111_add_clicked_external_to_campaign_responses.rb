class AddClickedExternalToCampaignResponses < ActiveRecord::Migration[8.1]
  def change
    add_column :campaign_responses, :clicked_external, :boolean, default: false, null: false
  end
end
