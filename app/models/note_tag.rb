class NoteTag < ApplicationRecord
 
  belongs_to :note, touch: true
  belongs_to :tag


end
