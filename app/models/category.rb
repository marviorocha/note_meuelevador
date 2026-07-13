class Category < ApplicationRecord
  has_many :subcategories, dependent: :destroy

#   validates :name, presence: true, uniqueness: { case_sensitive: false, message: "já existe" }
end
