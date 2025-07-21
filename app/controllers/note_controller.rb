class NoteController < ApplicationController
    def index
        if params[:query].present?

            @notes = Note.search(params[:query])
        else
            @notes = Note.all
        end
    end
end
