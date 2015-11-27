# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151127025525) do

  create_table "access_logs", force: :cascade do |t|
    t.integer  "entry_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "access_logs", ["entry_id"], name: "index_access_logs_on_entry_id", using: :btree

  create_table "entries", force: :cascade do |t|
    t.string   "site",               limit: 255
    t.string   "title",              limit: 255
    t.text     "description",        limit: 65535
    t.datetime "content_created_at"
    t.text     "text",               limit: 65535
    t.text     "html",               limit: 65535
    t.text     "image",              limit: 65535
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "url",                limit: 255
  end

end