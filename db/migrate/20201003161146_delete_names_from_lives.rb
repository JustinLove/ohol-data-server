class DeleteNamesFromLives < ActiveRecord::Migration[5.2]
  def up
    remove_index :lives, name: "index_name_on_lives"
    remove_column :lives, :name, :string
  end

  def down
    add_column :lives, :name, :string
    add_index :lives, "name gist_trgm_ops", name: "index_name_on_lives", using: :gist
  end
end
