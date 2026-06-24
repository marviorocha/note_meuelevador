# app/services/langbase_service.rb

class LangbaseService
  BASE_URL = "https://api.langbase.com/v1"

  def initialize
    @api_key = ENV.fetch("LANGBASE_API_KEY")
  end

  def ask(pipe:, message:)
    response = Faraday.post(
      "#{BASE_URL}/pipes/run",
      {
        name: pipe,
        messages: [
          {
            role: "user",
            content: message
          }
        ]
      }.to_json,
      headers
    )

    JSON.parse(response.body)
  end

  private

  def headers
    {
      "Authorization" => "Bearer #{@api_key}",
      "Content-Type" => "application/json"
    }
  end
end
