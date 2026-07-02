class AddCascadeToNoteTagsFk < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :note_tags, :notes
    add_foreign_key :note_tags, :notes, on_delete: :cascade
  end
end