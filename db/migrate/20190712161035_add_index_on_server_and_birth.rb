class AddIndexOnServerAndBirth < ActiveRecord::Migration[5.2]
  def change
    add_index :lives, [:server_id, :birth_time]
  end
end
