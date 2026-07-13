class Subcategory < ApplicationRecord
  has_many :notes, dependent: :delete_all
  belongs_to :category

#   validates :name, presence: true, uniqueness: { scope: :category_id, case_sensitive: false, message: "já existe nesta categoria" }
end
