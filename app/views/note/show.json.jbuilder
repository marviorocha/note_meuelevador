json.extract! @note, :id, :content, :status, :characters, :is_new, :created_at, :updated_at
json.author do
  json.extract! @note.author, :id, :name
end
json.subcategory do
  json.extract! @note.subcategory, :id, :name
  json.category do
    json.extract! @note.subcategory.category, :id, :name
  end
end
json.tags @note.tags do |tag|
  json.extract! tag, :id, :name
end
