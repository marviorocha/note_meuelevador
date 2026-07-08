class AddUniqueIndexesToCategoriesAndSubcategories < ActiveRecord::Migration[8.0]
  def change
    # Garante que nomes de categoria sejam únicos (case-insensitive via lower())
    add_index :categories, "LOWER(name)", unique: true, name: "index_categories_on_lower_name"

    # Garante que o nome da subcategoria seja único dentro de cada categoria
    add_index :subcategories, "LOWER(name), category_id", unique: true, name: "index_subcategories_on_lower_name_and_category_id"
  end
end
