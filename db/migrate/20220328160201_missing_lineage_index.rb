class MissingLineageIndex < ActiveRecord::Migration[5.2]
  def up
    add_index :lives, [:lineage, :chain]
  end

  def down
    remove_index :lives, [:lineage, :chain]
  end
end
