class RemoveMonuments < ActiveRecord::Migration[5.2]
  def change
    drop_table :monuments do |t|
      t.integer :server_id
      t.datetime :date
      t.integer :x
      t.integer :y
    end
  end
end
