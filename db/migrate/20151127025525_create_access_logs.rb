class CreateAccessLogs < ActiveRecord::Migration
  def change
    create_table :access_logs do |t|
      t.integer :entry_id
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :access_logs, :entry_id
  end
end
