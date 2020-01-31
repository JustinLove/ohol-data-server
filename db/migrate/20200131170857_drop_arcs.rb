class DropArcs < ActiveRecord::Migration[5.2]
  def change
    drop_table :arcs do |t|
      t.integer :server_id, :null => false
      t.datetime :start, :null => false
      t.datetime :end, :null => false
      t.bigint :seed, :null => false
    end
  end
end
