class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :account, null: false, foreign_key: true
      t.references :subscription, null: false, foreign_key: true
      t.string :number, null: false
      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: 'PKR'
      t.string :status, null: false, default: 'pending'
      t.date :issued_at, null: false
      t.date :due_at, null: false
      t.datetime :paid_at
      t.string :payment_method
      t.string :payment_reference
      t.text :notes

      t.timestamps
    end

    add_index :invoices, :number, unique: true
    add_index :invoices, :status
    add_index :invoices, :due_at
    add_index :invoices, [:account_id, :status]
  end
end
