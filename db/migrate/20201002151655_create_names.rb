class CreateNames < ActiveRecord::Migration[5.2]
  def change
    create_table :names do |t|
      t.string :name
    end

    #enable_extension :pg_trgm
    add_index :names, "name gist_trgm_ops", name: "index_name_on_names", using: :gist
    add_index :names, "name", name: "unique_name_on_names", unique: true

    add_reference :lives, :names, :foreign_key => true
  end
end
