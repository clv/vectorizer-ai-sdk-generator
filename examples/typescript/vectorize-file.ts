import { readFile, writeFile } from "node:fs/promises";
import { Configuration, VectorizationApi } from "@vectorizer-ai/sdk";

const apiId = process.env.VECTORIZER_API_ID;
const apiSecret = process.env.VECTORIZER_API_SECRET;
const inputPath = process.env.VECTORIZER_INPUT ?? "example.png";
const outputPath = process.env.VECTORIZER_OUTPUT ?? "result.svg";

if (!apiId || !apiSecret) {
  throw new Error("Set VECTORIZER_API_ID and VECTORIZER_API_SECRET.");
}

const api = new VectorizationApi(
  new Configuration({
    username: apiId,
    password: apiSecret,
  }),
);

const image = new Blob([await readFile(inputPath)]);
const result = await api.postVectorize({
  image,
  outputFileFormat: "svg",
});

await writeFile(outputPath, Buffer.from(await result.arrayBuffer()));
console.log(`Wrote ${outputPath}`);
