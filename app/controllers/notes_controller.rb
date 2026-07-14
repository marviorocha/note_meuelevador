class NotesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_note, only: [ :show, :edit, :update, :destroy ]

    def index
      # A busca é feita pelo InstantSearch.js direto no Typesense (client-side).
      # O controller só precisa renderizar a view com os dados do Typesense via JS.
    end

    def show
    end

    def new
        @note = Note.new
    end

    def create
        @note = Note.new(note_params)
        associate_new_subcategory!

        if @note.save
            redirect_to notes_path, notice: "Nota criada com sucesso."
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
        @authors = Author.all
        @categories = Category.all
        @subcategories = Subcategory.all
    end

    def update
        @note = Note.find(params[:id])
        @note.assign_attributes(note_params)
        associate_new_subcategory!

        if @note.save
            redirect_to notes_path, notice: "Nota atualizada com sucesso."
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @note.destroy
        respond_to do |format|
            format.html { redirect_to notes_path, notice: "Nota excluída com sucesso." }
            format.json { head :no_content }
            format.turbo_stream
        end
    end

    private

    def has_search_params?
        params.key?(:busca) || params.key?(:category) || params.key?(:subcategory)
    end

    def search_params
        params.permit(:busca, :category, :subcategory)
    end

    def set_note
        @note = Note.find(params[:id])
    end

    def note_params
        params.expect(note: [ :author_id, :category_id, :subcategory_id, :status, :content, :characters, :is_new ])
    end

    def associate_new_subcategory!
      category_id = params[:category_id].presence || @note.subcategory&.category_id
      new_subcategory_name = params[:new_subcategory_name].presence

      return if new_subcategory_name.blank?
      return if category_id.blank?

      @note.subcategory = Subcategory.find_or_initialize_by(
        name: new_subcategory_name,
        category_id: category_id
      )

      @note.subcategory.save! if @note.subcategory.new_record?
    end
end
