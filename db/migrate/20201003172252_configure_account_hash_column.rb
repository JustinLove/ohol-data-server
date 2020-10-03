class ConfigureAccountHashColumn < ActiveRecord::Migration[5.2]
  def up
    change_column :accounts, :account_hash, :string, :size => 40, :null => false
  end

  def down
    change_column :accounts, :account_hash, :string
  end
end
