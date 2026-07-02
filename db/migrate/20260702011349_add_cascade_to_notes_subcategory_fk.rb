class AddCascadeToNotesSubcategoryFk < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :notes, :subcategories
    add_foreign_key :notes, :subcategories, on_delete: :cascade
  end
end