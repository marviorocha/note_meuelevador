class CreateNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :notes do |t|
      t.text :resume
      t.text :content
      t.integer :character_count
      t.boolean :is_new
    #   t.references :section, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
   
      t.timestamps
    end
  end
end
