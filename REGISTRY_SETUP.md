# Registry Setup Runbook

This is the current release checklist for the official Vectorizer.AI SDKs and CLI.

## Current State

Done:

- SDK repositories exist under `https://github.com/clv`.
- SDK `v1.0.0` tags are already pushed.
- Go is published by Git tag and is available through the Go module proxy.
- PHP has a GitHub `v1.0.0` release, but still needs Packagist submission before `composer require vectorizer/ai` works.
- CLI `v1.0.0` is released at `https://github.com/clv/vectorizer-ai-cli/releases/tag/v1.0.0`.

Still blocked:

- Python, Java, .NET, and Ruby publish workflows are waiting for protected GitHub environment approval.
- Do not approve those waiting jobs until the matching registry-side trusted publishing setup below is complete.
- PyPI, npm, NuGet, Maven Central, RubyGems, and Packagist package-manager URLs currently do not resolve for these package names.

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

Registry action:

- Log in to `https://www.npmjs.com`.
- Create or claim the npm org/scope `@vectorizer-ai`.
- Configure trusted publishing for package `@vectorizer-ai/sdk`.
- Use these GitHub publisher settings:
  - Owner: `clv`
  - Repository name: `vectorizer-ai-js`
  - Workflow filename: `publish.yml`
  - Environment name: `npm`

Then approve this waiting GitHub environment job:

- `https://github.com/clv/vectorizer-ai-js/actions/runs/26796477833`

Verify:

- `https://www.npmjs.com/package/@vectorizer-ai/sdk`
- `npm install @vectorizer-ai/sdk`

Official reference:

- `https://docs.npmjs.com/trusted-publishers/`

### 3. NuGet

Goal: make `dotnet add package Vectorizer.AI` work.

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

Then approve this waiting GitHub environment job:

- `https://github.com/clv/vectorizer-ai-dotnet/actions/runs/26837289941`

Verify:

- `https://www.nuget.org/packages/Vectorizer.AI`
- `dotnet add package Vectorizer.AI`

Official reference:

- `https://learn.microsoft.com/en-us/nuget/nuget-org/trusted-publishing`

### 4. RubyGems

Goal: make `gem install vectorizer_ai` work.

Registry action:

- Log in to `https://rubygems.org`.
- Configure trusted publishing for gem `vectorizer_ai`.
- Use these GitHub publisher settings:
  - Repository owner: `clv`
  - Repository name: `vectorizer-ai-ruby`
  - Workflow filename: `publish.yml`
  - Environment name: `rubygems`

Then approve this waiting GitHub environment job:

- `https://github.com/clv/vectorizer-ai-ruby/actions/runs/26796477976`

Verify:

- `https://rubygems.org/gems/vectorizer_ai`
- `gem install vectorizer_ai`

Official reference:

- `https://guides.rubygems.org/trusted-publishing/`

### 5. Maven Central

Goal: make `ai.vectorizer:vectorizer-ai-java:1.0.0` work.

Registry action:

- Log in to `https://central.sonatype.com`.
- Create or verify the namespace `ai.vectorizer`.
- Complete the domain ownership verification for `vectorizer.ai` when Sonatype provides the required verification step.

GitHub secret action:

- In `clv/vectorizer-ai-java`, add these repository secrets:
  - `JRELEASER_MAVENCENTRAL_SONATYPE_USERNAME`
  - `JRELEASER_MAVENCENTRAL_SONATYPE_PASSWORD`
  - `JRELEASER_GPG_PUBLIC_KEY`
  - `JRELEASER_GPG_SECRET_KEY`
  - `JRELEASER_GPG_PASSPHRASE`

Use a dedicated company release-signing GPG key if there is no existing Cedar Lake Ventures publishing key.

Then approve this waiting GitHub environment job:

- `https://github.com/clv/vectorizer-ai-java/actions/runs/26796477798`

Verify:

- `https://central.sonatype.com/artifact/ai.vectorizer/vectorizer-ai-java`
- Maven/Gradle can resolve `ai.vectorizer:vectorizer-ai-java:1.0.0`.

Official references:

- `https://central.sonatype.org/register/namespace/`
- `https://central.sonatype.org/register/central-portal/`
- `https://jreleaser.org/guide/latest/continuous-integration/github-actions.html`

### 6. Packagist

Goal: make `composer require vectorizer/ai` work.

Registry action:

- Log in to `https://packagist.org`.
- Submit the public repository URL:
  - `https://github.com/clv/vectorizer-ai-php`
- Configure GitHub synchronization so future tags are imported automatically.

No GitHub environment approval is needed; the PHP `v1.0.0` GitHub release already exists.

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
2. npm
3. RubyGems
4. Packagist
5. NuGet
6. Maven Central

NuGet and Maven Central tend to have the most account/namespace friction, so they can run in parallel with the simpler registries if time matters.
