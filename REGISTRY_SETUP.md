# Registry Setup Runbook

This is the current release checklist for the official Vectorizer.AI SDKs and CLI.

## Current State

Done:

- SDK repositories exist under `https://github.com/clv`.
- SDK `v1.0.0` tags are already pushed.
- JavaScript is published to npm as `@vectorizer-ai/sdk@1.0.0`.
- .NET is published to NuGet as `Vectorizer.AI@1.0.0`.
- Ruby is published to RubyGems as `vectorizer_ai@1.0.1`. Version `1.0.0` was superseded immediately by `1.0.1` to fix an oversized gem packaging file list.
- Go is published by Git tag and is available through the Go module proxy.
- PHP is published to Packagist as `vectorizer/ai@v1.0.0`.
- CLI `v1.0.0` is released at `https://github.com/clv/vectorizer-ai-cli/releases/tag/v1.0.0`.
- Java is published to Maven Central as `ai.vectorizer:vectorizer-ai-java:1.0.0`.

Still blocked:

- Python is waiting for PyPI organization approval and trusted-publisher setup.
- The PyPI package-manager URL currently does not resolve for `vectorizer-ai-sdk`.

## Account Defaults

- Owner/company: Cedar Lake Ventures, Inc.
- Public product name: Vectorizer.AI
- Contact email: james@cedarlakeventures.com
- Website: `https://vectorizer.ai`
- GitHub owner: `clv`

Use company-controlled registry accounts where possible. Do not use tax or billing details unless a registry explicitly requires them.

## Package Coordinates

| Language | Registry | Package |
| --- | --- | --- |
| Python | PyPI | `vectorizer-ai-sdk` |
| TypeScript / JavaScript | npm | `@vectorizer-ai/sdk` |
| Java | Maven Central | `ai.vectorizer:vectorizer-ai-java` |
| .NET | NuGet | `Vectorizer.AI` |
| Go | Go module proxy | `github.com/clv/vectorizer-go` |
| PHP | Packagist | `vectorizer/ai` |
| Ruby | RubyGems | `vectorizer_ai` |
| CLI | GitHub Releases | `vectorizer` |

## James Action Checklist

### 1. PyPI

Goal: make `pip install vectorizer-ai-sdk` work.

Registry action:

- Log in to `https://pypi.org`.
- Create a pending trusted publisher for project `vectorizer-ai-sdk`.
- Use these GitHub publisher settings:
  - Owner: `clv`
  - Repository name: `vectorizer-ai-python`
  - Workflow filename: `publish.yml`
  - Environment name: `pypi`

Then approve this waiting GitHub environment job:

- `https://github.com/clv/vectorizer-ai-python/actions/runs/26796477737`

Verify:

- `https://pypi.org/project/vectorizer-ai-sdk/`
- `pip install vectorizer-ai-sdk`

Official reference:

- `https://docs.pypi.org/trusted-publishers/using-a-publisher/`

### 2. npm

Goal: make `npm install @vectorizer-ai/sdk` work.

Done: `@vectorizer-ai/sdk@1.0.0` is published and verified installable.

Registry action:

- Log in to `https://www.npmjs.com`.
- Create or claim the npm org/scope `@vectorizer-ai`.
- Configure trusted publishing for package `@vectorizer-ai/sdk`.
- Use these GitHub publisher settings:
  - Owner: `clv`
  - Repository name: `vectorizer-ai-js`
  - Workflow filename: `publish.yml`
  - Environment name: `npm`

The original waiting GitHub environment job was cancelled because `1.0.0` was manually bootstrapped before trusted publishing was configured.

Verify:

- `https://www.npmjs.com/package/@vectorizer-ai/sdk`
- `npm install @vectorizer-ai/sdk`

Official reference:

- `https://docs.npmjs.com/trusted-publishers/`

### 3. NuGet

Goal: make `dotnet add package Vectorizer.AI` work.

Done: `Vectorizer.AI@1.0.0` is published to NuGet and verified installable.

Registry action:

- Log in to `https://www.nuget.org`.
- Configure trusted publishing for package `Vectorizer.AI`.
- Use these GitHub publisher settings:
  - Repository owner: `clv`
  - Repository name: `vectorizer-ai-dotnet`
  - Workflow filename: `publish.yml`
  - Environment name: `nuget`

GitHub secret action:

- Done: in `clv/vectorizer-ai-dotnet`, repository secret `NUGET_USER` is set to `jamesd_clv`.

Done: the corrected GitHub environment job was approved and completed:

- `https://github.com/clv/vectorizer-ai-dotnet/actions/runs/26837289941`

Verify:

- `https://www.nuget.org/packages/Vectorizer.AI`
- `dotnet add package Vectorizer.AI`

Official reference:

- `https://learn.microsoft.com/en-us/nuget/nuget-org/trusted-publishing`

### 4. RubyGems

Goal: make `gem install vectorizer_ai` work.

Done: `vectorizer_ai@1.0.1` is published to RubyGems.

Done: RubyGems pending trusted publishing was configured with these GitHub publisher settings:

- Repository owner: `clv`
- Repository name: `vectorizer-ai-ruby`
- Workflow filename: `publish.yml`
- Environment name: `rubygems`

Done: the original `1.0.0` job completed, then `1.0.1` was published with a corrected gemspec file list to avoid including CI-installed `vendor/bundle` dependencies:

- `https://github.com/clv/vectorizer-ai-ruby/actions/runs/26796477976`
- `https://github.com/clv/vectorizer-ai-ruby/actions/runs/26838184485`

Verify:

- `https://rubygems.org/gems/vectorizer_ai`
- `gem install vectorizer_ai`

Official reference:

- `https://guides.rubygems.org/trusted-publishing/`

### 5. Maven Central

Goal: make `ai.vectorizer:vectorizer-ai-java:1.0.0` work.

Done:

- Java SDK `main` and tag `v1.0.0` were moved to the Maven Central-published commit.
- Gradle publication now includes main, sources, and Javadocs artifacts.
- JReleaser is configured with `applyMavenCentralRules: true`, namespace `ai.vectorizer`, and bearer-token authorization for the Central Portal Publisher API.
- GitHub GPG and Maven Central token secrets are set in `clv/vectorizer-ai-java`.
- Public release-signing key is on `hkps://keyserver.ubuntu.com`:
  - `B025 2785 118E 7994 526A 8CF6 D89B D63D 230C 4F2C`
- The corrected publish workflow completed:
  - `https://github.com/clv/vectorizer-ai-java/actions/runs/26841248695`
- The GitHub release was created:
  - `https://github.com/clv/vectorizer-ai-java/releases/tag/v1.0.0`
- The artifact resolves from Maven Central with Gradle.

Verify:

- `https://central.sonatype.com/artifact/ai.vectorizer/vectorizer-ai-java`
- Maven/Gradle can resolve `ai.vectorizer:vectorizer-ai-java:1.0.0`.

Official references:

- `https://central.sonatype.org/register/namespace/`
- `https://central.sonatype.org/register/central-portal/`
- `https://central.sonatype.org/publish/publish-portal-api/`
- `https://jreleaser.org/guide/latest/continuous-integration/github-actions.html`

### 6. Packagist

Goal: make `composer require vectorizer/ai` work.

Done:

- The public repository was submitted:
  - `https://github.com/clv/vectorizer-ai-php`
- Packagist package page:
  - `https://packagist.org/packages/vectorizer/ai`
- GitHub synchronization is configured through an active `push` webhook on `clv/vectorizer-ai-php`.
- Packagist Composer metadata resolves `v1.0.0` to commit `24a6fe43e0666db50eb36bc93099159247950544`.

Verify:

- `https://packagist.org/packages/vectorizer/ai`
- `composer require vectorizer/ai`

Official reference:

- `https://packagist.org/about`

## Approval Order

1. Complete one registry setup item.
2. Approve only that registry's waiting GitHub environment job.
3. Wait for the job to finish.
4. Confirm the package appears in the registry and can be installed.
5. Move to the next registry.

Recommended order for fastest deploy confidence:

1. PyPI

Maven Central and Packagist are done. The remaining registry work is PyPI trusted publishing once the organization is approved.
