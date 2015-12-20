class CreateEntryWordRelations < ActiveRecord::Migration
  def change
    create_table :entry_word_relations do |t|
      t.integer :entry_id
      t.integer :word_id

      t.timestamps null: false
    end
    add_index :entry_word_relations, :entry_id
    add_index :entry_word_relations, :word_id
  end
end
