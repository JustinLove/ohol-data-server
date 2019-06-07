class CreateServers < ActiveRecord::Migration[5.2]
  def change
    create_table :servers do |t|
      t.string :server_name
      t.datetime :created_at
      t.datetime :removed_at
    end
  end
end
