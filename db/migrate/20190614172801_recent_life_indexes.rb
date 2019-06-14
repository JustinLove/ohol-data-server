class RecentLifeIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :lives, :server_id
    add_index :lives, :birth_time
    add_index :lives, :death_time
  end
end
