class Subcategory < ApplicationRecord
  has_many :notes, dependent: :delete_all # ou :destroy se precisar callbacks em Note
  belongs_to :category
end
