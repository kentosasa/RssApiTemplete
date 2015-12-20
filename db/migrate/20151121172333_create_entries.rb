class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :site
      t.string :title
      t.text :description
      t.datetime :content_created_at
      t.text :image
      t.string :category

      t.timestamps null: false
    end
  end
end
