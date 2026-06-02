import os
from pathlib import Path

import vectorizer_ai
from vectorizer_ai.api.vectorization_api import VectorizationApi


api_id = os.environ["VECTORIZER_API_ID"]
api_secret = os.environ["VECTORIZER_API_SECRET"]
input_path = Path(os.environ.get("VECTORIZER_INPUT", "example.png"))
output_path = Path(os.environ.get("VECTORIZER_OUTPUT", "result.svg"))

configuration = vectorizer_ai.Configuration(
    username=api_id,
    password=api_secret,
)

with vectorizer_ai.ApiClient(configuration) as api_client:
    api = VectorizationApi(api_client)
    result = api.post_vectorize(
        image=input_path.read_bytes(),
        output_file_format="svg",
        _request_timeout=180,
    )

output_path.write_bytes(result)
print(f"Wrote {output_path}")
