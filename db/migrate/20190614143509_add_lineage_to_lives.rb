class AddLineageToLives < ActiveRecord::Migration[5.2]
  def change
    add_column :lives, :lineage, :integer
    add_index :lives, [:server_id, :epoch, :lineage]
  end
end
