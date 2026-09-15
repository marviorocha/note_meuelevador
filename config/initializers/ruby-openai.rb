# config/initializers/openai.rb
OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENROUTER_API_KEY")
  config.uri_base = "https://openrouter.ai/api/v1"

  # Cabeçalhos opcionais exigidos/recomendados pelo OpenRouter
  config.extra_headers = {
    "HTTP-Referer" => ENV.fetch("SITE_URL", "http://localhost:3000"),
    "X-Title" => "Notas MeuElevador"
  }
end
