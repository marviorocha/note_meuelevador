class Subcategory < ApplicationRecord
    belongs_to :category, dependent: :destroy
    has_many :notes, dependent: :destroy
end
