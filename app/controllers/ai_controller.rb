class AiController < ApplicationController
  skip_before_action :verify_authenticity_token
  def ask
    result = LangbaseService.new.ask(
      pipe: "consultor-elevadores",
      message: params[:question]
    )

    render json: result
  end
end
