class ExpandSeedColumn < ActiveRecord::Migration[5.2]
  def up
    change_column :arcs, :seed, :bigint
  end

  def down
    change_column :arcs, :seed, :integer
  end
end
