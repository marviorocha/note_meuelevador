require "typesense"

TYPESENSE_CLIENT = Typesense::Client.new(
  api_key: ENV.fetch("TYPESENSE_API_KEY"),
  nodes: [
    {
      host: ENV.fetch("TYPESENSE_HOST"),
      port: 8108,
      protocol: Rails.env.development? ? "http" : "https"
    }
  ],
  connection_timeout_seconds: 5
)
