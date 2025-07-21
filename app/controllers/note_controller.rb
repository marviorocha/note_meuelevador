class NoteController < ApplicationController
    def index
        @notes = Note.first(20)
        @categories = Category.all
    end
end
