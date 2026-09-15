class AiController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :ask ]
  before_action :authenticate_user!, only: [ :generate_note ]

  def ask
    result = LangbaseService.new.ask(
      pipe: "consultor-elevadores",
      message: params[:question]
    )

    render json: result
  end

  def generate_note
    category = resolve_category
    subcategory = resolve_subcategory

    if category.blank? && subcategory.blank?
      render json: { error: "Por favor, selecione uma Categoria ou Subcategoria antes de gerar a nota." }, status: :unprocessable_entity
      return
    end

    service = AiNoteService.new
    content = service.generate(
      category: category,
      subcategory: subcategory,
      context: params[:context]
    )

    render json: { content: content }
  rescue => e
    Rails.logger.error "Erro na geração de nota por IA: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def resolve_category
    return params[:category_name].presence if params[:category_name].present?

    if params[:category_id].present?
      Category.find_by(id: params[:category_id])&.name
    end
  end

  def resolve_subcategory
    return params[:new_subcategory_name].presence if params[:new_subcategory_name].present?
    return params[:subcategory_name].presence if params[:subcategory_name].present?

    if params[:subcategory_id].present?
      Subcategory.find_by(id: params[:subcategory_id])&.name
    end
  end
end
