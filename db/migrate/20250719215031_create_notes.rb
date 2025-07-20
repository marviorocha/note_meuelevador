class CreateNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :notes do |t|
      t.references :author, null: false, foreign_key: true
      t.references :subcategory, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :characters
      t.boolean :is_new, default: false

      t.timestamps
    end
  end
end
