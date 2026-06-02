# Publishing

This repository is the source of truth for regenerating the official Vectorizer.AI API SDKs from the public OpenAPI document.

For one-time registry bootstrap status, account details, and historical setup notes, see `REGISTRY_SETUP.md`. This file is the forward-looking runbook for cutting future SDK versions.

## Release Rule

Never move or re-use a version after it has reached a public package registry. Package registries generally treat versions as immutable. If a release has a problem after publication, fix it in a new patch version such as `1.0.2`.

The Git tag must match the package version in each SDK repository. All publish workflows enforce this.

## Normal Release Process

1. Update the OpenAPI spec in the website/API repo.
2. Decide the SDK version using SemVer.
3. Generate SDKs from the intended spec:

   ```powershell
   .\generate.ps1 -Version 1.0.1 -SpecUrl https://vectorizer.ai/api/openapi.json
   ```

   Use `http://localhost:9000/api/openapi.json` instead of production when validating unreleased API docs locally.

4. Run generator checks:

   ```powershell
   .\test.ps1 -Deep
   ```

5. Copy each generated `output/<language>` tree into the matching SDK repository.
6. Review each SDK repository diff. Preserve repo-owned files such as `.git`, `.github`, publishing docs, and registry workflow files.
7. Run each SDK repo's local checks where practical.
8. Commit the SDK repo update.
9. Push a matching SemVer tag, for example `v1.0.1`.
10. Approve any protected GitHub environment job for that SDK.
11. Verify the registry package resolves before announcing it.

## SDK Repository Matrix

| Language | Generator output | Repository | Package | Publish trigger | Gate |
| --- | --- | --- | --- | --- | --- |
| Python | `output/python` | `clv/vectorizer-ai-python` | `vectorizer-ai-sdk` | `.github/workflows/publish.yml` on `v*.*.*` tag | `pypi` |
| TypeScript / JavaScript | `output/typescript` | `clv/vectorizer-ai-js` | `@vectorizer-ai/sdk` | `.github/workflows/publish.yml` on `v*.*.*` tag | `npm` |
| Java | `output/java` | `clv/vectorizer-ai-java` | `ai.vectorizer:vectorizer-ai-java` | `.github/workflows/publish.yml` on `v*.*.*` tag | `maven-central` |
| .NET | `output/csharp` | `clv/vectorizer-ai-dotnet` | `Vectorizer.AI` | `.github/workflows/publish.yml` on `v*.*.*` tag | `nuget` |
| Go | `output/go` | `clv/vectorizer-go` | `github.com/clv/vectorizer-go` | `.github/workflows/release.yml` on `v*.*.*` tag | none |
| PHP | `output/php` | `clv/vectorizer-ai-php` | `vectorizer/ai` | `.github/workflows/release.yml` on `v*.*.*` tag; Packagist follows tags by webhook | none |
| Ruby | `output/ruby` | `clv/vectorizer-ai-ruby` | `vectorizer_ai` | `.github/workflows/publish.yml` on `v*.*.*` tag | `rubygems` |

## Registry Setup Already In Place

- npm: `@vectorizer-ai/sdk` exists and `1.0.0` was published.
- NuGet: `Vectorizer.AI` exists, trusted publishing works, and `NUGET_USER` is set.
- RubyGems: `vectorizer_ai` exists and trusted publishing works.
- Maven Central: namespace `ai.vectorizer` is verified; Java uses JReleaser with bearer-token auth and file-based GPG signing secrets.
- Packagist: `vectorizer/ai` exists and GitHub push webhook is active.
- Go: tags/releases are enough for normal Go module consumption.
- PyPI: complete the pending trusted-publisher setup once the Cedar Lake Ventures organization is approved.

## Version Verification Points

Before tagging, confirm the generated/package version in each repo:

| Repository | Version source |
| --- | --- |
| `vectorizer-ai-python` | `tool.poetry.version` in `pyproject.toml` |
| `vectorizer-ai-js` | `version` in `package.json` |
| `vectorizer-ai-java` | Gradle project `version` in `build.gradle` |
| `vectorizer-ai-dotnet` | `<Version>` in `src/Vectorizer.AI/Vectorizer.AI.csproj` |
| `vectorizer-go` | Git tag only |
| `vectorizer-ai-php` | Git tag only; `composer.json` intentionally has no `version` |
| `vectorizer-ai-ruby` | `VectorizerAI::VERSION` in `lib/vectorizer_ai/version.rb` |

## Post-Publish Checks

Use registry metadata first; it is faster and less noisy than a full install.

```powershell
Invoke-RestMethod https://pypi.org/pypi/vectorizer-ai-sdk/json
Invoke-RestMethod https://registry.npmjs.org/@vectorizer-ai%2fsdk/latest
Invoke-RestMethod https://api.nuget.org/v3/registration5-semver1/vectorizer.ai/index.json
Invoke-RestMethod https://repo.packagist.org/p2/vectorizer/ai.json
```

Also verify:

- RubyGems page: `https://rubygems.org/gems/vectorizer_ai`
- Maven Central page: `https://central.sonatype.com/artifact/ai.vectorizer/vectorizer-ai-java`
- Maven artifact: `https://repo1.maven.org/maven2/ai/vectorizer/vectorizer-ai-java/<version>/vectorizer-ai-java-<version>.pom`
- Go module proxy: `https://proxy.golang.org/github.com/clv/vectorizer-go/@v/v<version>.info`
- GitHub releases exist for all SDK repos.

## Environment Approvals

Publishing jobs for Python, npm, NuGet, Java, and Ruby use protected GitHub environments. After pushing a tag, approve only the job for the SDK you are releasing.

Useful commands:

```powershell
& 'C:\Program Files\GitHub CLI\gh.exe' run list --repo clv/vectorizer-ai-python --limit 10
& 'C:\Program Files\GitHub CLI\gh.exe' run view <run-id> --repo clv/vectorizer-ai-python
```

If approving through the GitHub API, inspect pending deployments first and approve the exact environment id returned by GitHub.

## Registry Notes

- Python publishes with PyPI trusted publishing, no long-lived API token.
- npm should use trusted publishing for future releases. The first public package was bootstrapped manually.
- NuGet trusted publishing returns an API key inside the workflow; the repo secret `NUGET_USER` identifies the NuGet account.
- RubyGems trusted publishing is configured for the GitHub repo/workflow/environment.
- Java publishes through JReleaser to the Central Portal Publisher API. Use `JRELEASER_MAVENCENTRAL_SONATYPE_TOKEN` for the base64 `username:password` token and `authorization: BEARER`.
- PHP does not push to Packagist from GitHub Actions. Packagist discovers releases through its GitHub webhook.
- Go does not have a central registry push. Tags are the release mechanism.
