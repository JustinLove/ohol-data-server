class CreateArcs < ActiveRecord::Migration[5.2]
  def change
    create_table :arcs do |t|
      t.integer :server_id, :null => false
      t.datetime :start, :null => false
      t.datetime :end, :null => false
      t.integer :seed, :null => false
    end
  end
end
