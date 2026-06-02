using Vectorizer.AI.Api;
using Vectorizer.AI.Client;

var apiId = Environment.GetEnvironmentVariable("VECTORIZER_API_ID");
var apiSecret = Environment.GetEnvironmentVariable("VECTORIZER_API_SECRET");
var inputPath = Environment.GetEnvironmentVariable("VECTORIZER_INPUT") ?? "example.png";
var outputPath = Environment.GetEnvironmentVariable("VECTORIZER_OUTPUT") ?? "result.svg";

var config = new Configuration
{
    Username = apiId,
    Password = apiSecret,
};

var api = new VectorizationApi(config);
using var image = File.OpenRead(inputPath);
using var result = api.PostVectorize(
    image: image,
    outputFileFormat: "svg");

using var output = File.Create(outputPath);
result.CopyTo(output);
Console.WriteLine($"Wrote {outputPath}");
