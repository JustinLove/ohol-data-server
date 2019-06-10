class CreateLifelogFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :lifelog_files do |t|
      t.string :path
      t.datetime :fetched_at
      t.index :path, :unique => true
    end
  end
end
