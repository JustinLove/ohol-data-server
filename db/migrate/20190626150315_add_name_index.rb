class AddNameIndex < ActiveRecord::Migration[5.2]
  def change
    enable_extension :pg_trgm
    add_index :lives, "name gist_trgm_ops", name: "index_name_on_lives", using: :gist
  end
end
