class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :val

      t.timestamps null: false
    end
    add_index :words, :val
  end
end
