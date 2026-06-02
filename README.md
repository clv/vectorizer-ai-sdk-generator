# Vectorizer.AI SDKs

This workspace generates official Vectorizer.AI API SDKs from the public OpenAPI 3.0 specification.

The curated SDK set is intentionally broad without trying to cover every OpenAPI generator target:

- Python
- TypeScript / JavaScript
- Java
- C#
- Go
- PHP
- Ruby

The generated clients live under `output/<language>`.

The scripts download OpenAPI Generator CLI on first use and keep the jar as a local cache. Generated SDK source is written
under `output/` and then published to the per-language SDK repositories; generator-local outputs and build caches are not
committed here.

## Generate

Run this while the Vectorizer.AI website dev server is running locally:

```powershell
.\generate.ps1
```

By default this fetches:

```text
http://localhost:9000/api/openapi.json
```

To generate from production:

```powershell
.\generate.ps1 -SpecUrl https://vectorizer.ai/api/openapi.json
```

To generate a subset:

```powershell
.\generate.ps1 -Languages python,typescript
```

## Validate

Fast checks:

```powershell
.\test.ps1
```

Deeper checks for toolchains available on this machine:

```powershell
.\test.ps1 -Deep
```

## Publishing

Use [PUBLISHING.md](PUBLISHING.md) for the repeatable SDK release process. Use [REGISTRY_SETUP.md](REGISTRY_SETUP.md) for one-time registry setup status and historical notes.

## Publishing Names

These package coordinates are what the website documentation expects:

| Language | Package |
| --- | --- |
| Python | `vectorizer-ai-sdk` |
| TypeScript | `@vectorizer-ai/sdk` |
| Java | `ai.vectorizer:vectorizer-ai-java` |
| C# | `Vectorizer.AI` |
| Go | `github.com/clv/vectorizer-go` |
| PHP | `vectorizer/ai` |
| Ruby | `vectorizer_ai` |

Before publishing to public registries, choose the SDK license and update the language-specific package metadata if it
should differ from the generator defaults.

## Authentication

All SDKs use HTTP Basic authentication. Use the Vectorizer.AI API Id as the username and the API Secret as the password.

## API Notes

`vectorize` and `download` return binary file contents. The concrete type varies by language: for example, Python returns a `bytearray`, TypeScript returns a `Blob`, Java returns a `File`, and Go returns an `*os.File`.

The API accepts image input as exactly one of:

- `image`
- `image.url`
- `image.base64`
- `image.token`

The generated clients expose these dotted form fields as idiomatic language property names.
