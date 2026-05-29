module Api
  module V1
    class NotesController < ApiController
      before_action :set_note, only: %i[show update destroy]

      # GET /api/v1/notes
      def index
        @notes = Note.includes(:author, :subcategory, :tags).all
      end

      # GET /api/v1/notes/1
      def show
      end

      # POST /api/v1/notes
      def create
        @note = Note.new(note_params_with_associations)

        if @note.save
          if params[:tags].present?
            @note.tags = Array(params[:tags]).map { |name| Tag.find_or_create_by(name: name) }
          end
          render :show, status: :created
        else
          render json: @note.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/notes/1
      def update
        if @note.update(note_params_with_associations)
          if params[:tags].present?
            @note.tags = Array(params[:tags]).map { |name| Tag.find_or_create_by(name: name) }
          end
          render :show
        else
          render json: @note.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/notes/1
      def destroy
        @note.destroy
        head :no_content
      end

      private

      def set_note
        @note = Note.find(params[:id])
      end

      def note_params_with_associations
        params_hash = params.require(:note).permit(:status, :content, :characters, :is_new, :author_id, :subcategory_id, :author_name, :subcategory_name, :category_name).to_h

        if params_hash[:author_name].present?
          author = Author.find_or_create_by(name: params_hash.delete(:author_name))
          params_hash[:author_id] = author.id
        end

        if params_hash[:category_name].present? || params_hash[:subcategory_name].present?
          category_name = params_hash.delete(:category_name) || @note&.subcategory&.category&.name
          subcategory_name = params_hash.delete(:subcategory_name) || @note&.subcategory&.name

          if category_name.present? && subcategory_name.present?
            category = Category.find_or_create_by(name: category_name)
            subcategory = Subcategory.find_or_create_by(name: subcategory_name, category: category)
            params_hash[:subcategory_id] = subcategory.id
          end
        end

        params_hash
      end

      def note_params
        params.expect(note: [:author_id, :subcategory_id, :status, :content, :characters, :is_new])
      end
    end
  end
end
