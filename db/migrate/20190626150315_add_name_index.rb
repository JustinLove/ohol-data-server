class AddNameIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :lives, "to_tsvector(CAST('simple' AS regconfig), (COALESCE(\"name\", '')))", name: "index_name_on_lives", using: :gin
  end
end
