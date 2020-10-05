class RemoveAccountHashFromLives < ActiveRecord::Migration[5.2]
  def change
    remove_index :lives, :account_hash
    remove_column :lives, :account_hash, :string, :size => 40, :null => false
  end
end
