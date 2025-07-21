class NoteController < ApplicationController
    def index
        @notes = Note.first(30)
        @categories = Category.all
    end
end
