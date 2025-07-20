class Note < ApplicationRecord
  belongs_to :author
  belongs_to :subcategory
  has_many :note_tags
  has_many :tags, through: :note_tags
end
