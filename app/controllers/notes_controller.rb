class NotesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_note, only: [ :show, :edit, :update, :destroy ]

    def index
        if has_search_params?
            query = search_params[:busca].to_s
            search_options = {}
            filters = []

            if search_params[:category].present?
                filters << "category.name:'#{search_params[:category]}'"
            end
            
            if search_params[:subcategory].present?
                filters << "subcategory.name:'#{search_params[:subcategory]}'"
            end

            search_options[:filters] = filters.join(' AND ') if filters.any?

            @notes = Note.search(query, search_options)
        else
            @notes = Note.all
        end
        
        @categories = Category.select(:name).distinct.order(:name)
        @category_counts = Note.joins(subcategory: :category).group('categories.name').count
        @subcategory_counts = Note.joins(:subcategory).group('subcategories.name').count
        
        @category_tree = Subcategory.joins(:category)
                                    .order('categories.name', 'subcategories.name')
                                    .pluck('categories.name', 'subcategories.name')
                                    .each_with_object({}) do |(cat_name, sub_name), tree|
                                      tree[cat_name] ||= []
                                      tree[cat_name] << sub_name unless tree[cat_name].include?(sub_name)
                                    end
    end

    def show
    end

    def new
        @note = Note.new
    end

    def create
        @note = Note.new(note_params)
        @note.tag_names = params[:tag_names] if params[:tag_names].present?

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
        if @note.update(note_params)
            if params[:tag_names].present?
                @note.tags = params[:tag_names].split(",").map(&:strip).reject(&:blank?).map do |name|
                    Tag.find_or_create_by(name: name)
                end
            end
            respond_to do |format|
                format.html { redirect_to notes_path, notice: "Nota atualizada com sucesso." }
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
        params.expect(note: [ :author_id, :subcategory_id, :status, :content, :characters, :is_new ])
    end
end
