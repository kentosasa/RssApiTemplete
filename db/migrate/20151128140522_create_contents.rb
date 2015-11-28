class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.integer :entry_id
      t.text :text
      t.text :html

      t.timestamps null: false
    end
    add_index :contents, :entry_id
  end
end
