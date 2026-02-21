class CreateDashboardSummaries < ActiveRecord::Migration[8.1]
  def change
    create_table :dashboard_summaries do |t|
      t.references :account, null: false, foreign_key: true
      t.string :period
      t.text :summary
      t.jsonb :strengths
      t.jsonb :improvements
      t.text :action_item
      t.datetime :generated_at

      t.timestamps
    end
    add_index :dashboard_summaries, [:account_id, :period], unique: true
  end
end
