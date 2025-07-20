class NoteController < ApplicationController
    def index
        @notes = Note.all
        @categories = Category.all
    end
end
