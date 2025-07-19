class Note < ApplicationRecord
  belongs_to :subsection
  belongs_to :section
  belongs_to :user
  has_and_belongs_to_many :categories
end
