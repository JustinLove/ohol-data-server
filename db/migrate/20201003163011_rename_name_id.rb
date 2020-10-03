class RenameNameId < ActiveRecord::Migration[5.2]
  def change
    rename_column :lives, :names_id, :name_id
  end
end
