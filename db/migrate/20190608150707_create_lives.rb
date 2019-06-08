class CreateLives < ActiveRecord::Migration[5.2]
  def change
    create_table :lives do |t|
      t.integer :server_id, :null => false
      t.integer :epoch, :null => false
      t.integer :playerid, :null => false
      t.string :account_hash, :size => 40, :null => false
      t.datetime :birth_time
      t.integer :birth_x
      t.integer :birth_y
      t.integer :birth_population
      t.datetime :death_time
      t.integer :death_x
      t.integer :death_y
      t.integer :death_population
      t.integer :parent
      t.integer :chain
      t.string :gender, :size => 1
      t.float :age
      t.string :cause, :size =>20
      t.integer :killer
      t.string :name

      t.index [:server_id, :epoch, :playerid]
      t.index [:server_id, :epoch, :parent]
      t.index :account_hash
    end
  end
end
