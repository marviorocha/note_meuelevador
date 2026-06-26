require "typesense"

TYPESENSE_CLIENT = Typesense::Client.new(
  api_key: ENV.fetch("TYPESENSE_API_KEY"),
  nodes: [
    {
      host: ENV.fetch("TYPESENSE_HOST"),
      port: 443,
      protocol: "https"
    }
  ],
  connection_timeout_seconds: 5
)
