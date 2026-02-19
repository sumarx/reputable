class CreatePaymentProofs < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_proofs do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending_review'
      t.text :admin_notes
      t.datetime :submitted_at, null: false
      t.datetime :reviewed_at

      t.timestamps
    end

    add_index :payment_proofs, :status
    add_index :payment_proofs, :submitted_at
  end
end
