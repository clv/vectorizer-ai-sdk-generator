import ai.vectorizer.api.VectorizationApi;
import ai.vectorizer.invoker.ApiClient;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;

public class VectorizeFile {
  public static void main(String[] args) throws Exception {
    String apiId = System.getenv("VECTORIZER_API_ID");
    String apiSecret = System.getenv("VECTORIZER_API_SECRET");
    Path input = Path.of(System.getenv().getOrDefault("VECTORIZER_INPUT", "example.png"));
    Path output = Path.of(System.getenv().getOrDefault("VECTORIZER_OUTPUT", "result.svg"));

    ApiClient client = new ApiClient();
    client.setUsername(apiId);
    client.setPassword(apiSecret);

    VectorizationApi api = new VectorizationApi(client);
    File result = api.postVectorize(VectorizationApi.PostVectorizeRequest.newBuilder()
        .image(input.toFile())
        .outputFileFormat("svg")
        .build());

    Files.copy(result.toPath(), output);
    System.out.println("Wrote " + output);
  }
}
