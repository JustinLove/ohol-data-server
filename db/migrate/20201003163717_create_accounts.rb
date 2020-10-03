class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.string :account_hash
      t.index :account_hash, unique: true
    end

    add_reference :lives, :account, :foreign_key => true
  end
end
