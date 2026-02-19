class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :account, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true
      t.string :status, null: false, default: 'trial'
      t.datetime :trial_ends_at
      t.date :current_period_start
      t.date :current_period_end
      t.datetime :cancelled_at

      t.timestamps
    end

    add_index :subscriptions, :status
    add_index :subscriptions, :trial_ends_at
    add_index :subscriptions, :current_period_end
  end
end
