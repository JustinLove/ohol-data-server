# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_07_12_161035) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "lifelog_files", force: :cascade do |t|
    t.string "path"
    t.datetime "fetched_at"
    t.index ["path"], name: "index_lifelog_files_on_path", unique: true
  end

  create_table "lives", force: :cascade do |t|
    t.integer "server_id", null: false
    t.integer "epoch", null: false
    t.integer "playerid", null: false
    t.string "account_hash", null: false
    t.datetime "birth_time"
    t.integer "birth_x"
    t.integer "birth_y"
    t.integer "birth_population"
    t.datetime "death_time"
    t.integer "death_x"
    t.integer "death_y"
    t.integer "death_population"
    t.integer "parent"
    t.integer "chain"
    t.string "gender"
    t.float "age"
    t.string "cause"
    t.integer "killer"
    t.string "name"
    t.integer "lineage"
    t.index ["account_hash"], name: "index_lives_on_account_hash"
    t.index ["birth_time"], name: "index_lives_on_birth_time"
    t.index ["death_time"], name: "index_lives_on_death_time"
    t.index ["name"], name: "index_name_on_lives", opclass: :gist_trgm_ops, using: :gist
    t.index ["server_id", "birth_time"], name: "index_lives_on_server_id_and_birth_time"
    t.index ["server_id", "epoch", "lineage"], name: "index_lives_on_server_id_and_epoch_and_lineage"
    t.index ["server_id", "epoch", "parent"], name: "index_lives_on_server_id_and_epoch_and_parent"
    t.index ["server_id", "epoch", "playerid"], name: "index_lives_on_server_id_and_epoch_and_playerid", unique: true
    t.index ["server_id"], name: "index_lives_on_server_id"
  end

  create_table "monuments", force: :cascade do |t|
    t.integer "server_id"
    t.datetime "date"
    t.integer "x"
    t.integer "y"
  end

  create_table "servers", force: :cascade do |t|
    t.string "server_name"
  end

end
