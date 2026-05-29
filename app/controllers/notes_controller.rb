class NotesController < ApplicationController
    before_action :set_note, only: [:show, :edit, :update, :destroy]

    def index
        if params[:query].present?
            @notes = Note.search(params[:query])
        else
            @notes = Note.all
        end
    end

    def show
    end

    def edit
        @authors = Author.all
        @categories = Category.all
        @subcategories = Subcategory.all
    end

    def update
        if @note.update(note_params)
            if params[:tag_names].present?
                @note.tags = params[:tag_names].split(",").map(&:strip).reject(&:blank?).map do |name|
                    Tag.find_or_create_by(name: name)
                end
            end
            respond_to do |format|
                format.html { redirect_to notes_path, notice: 'Nota atualizada com sucesso.' }
                format.turbo_stream
            end
        else
            @authors = Author.all
            @categories = Category.all
            @subcategories = Subcategory.all
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @note.destroy
        respond_to do |format|
            format.html { redirect_to notes_path, notice: 'Nota excluída com sucesso.' }
            format.json { head :no_content }
            format.turbo_stream
        end
    end

    private

    def set_note
        @note = Note.find(params[:id])
    end

    def note_params
        params.expect(note: [:author_id, :subcategory_id, :status, :content, :characters, :is_new])
    end
end
