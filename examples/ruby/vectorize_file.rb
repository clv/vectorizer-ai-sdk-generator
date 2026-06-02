require "vectorizer_ai"

api_id = ENV.fetch("VECTORIZER_API_ID")
api_secret = ENV.fetch("VECTORIZER_API_SECRET")
input_path = ENV.fetch("VECTORIZER_INPUT", "example.png")
output_path = ENV.fetch("VECTORIZER_OUTPUT", "result.svg")

VectorizerAI.configure do |config|
  config.username = api_id
  config.password = api_secret
end

api = VectorizerAI::VectorizationApi.new
result = api.post_vectorize(image: File.open(input_path, "rb"), output_file_format: "svg")

File.binwrite(output_path, File.binread(result.path))
puts "Wrote #{output_path}"
