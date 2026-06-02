# Registry Setup Runbook

This file records the registry-side setup needed to publish the official Vectorizer.AI SDKs. The SDK repositories and `v1.0.0` tags already exist; the package registries still need account/namespace setup before the waiting GitHub Actions jobs should be approved.

## Account Defaults

- Owner/company: Cedar Lake Ventures, Inc.
- Public product name: Vectorizer.AI
- Contact email: james@cedarlakeventures.com
- Website: https://vectorizer.ai
- GitHub owner: clv

Do not use tax or billing details unless a registry explicitly requires them. Do not approve a protected GitHub publish environment until the matching registry setup below is complete.

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

## Current Release State

- `v1.0.0` tags have been pushed for all SDK repositories.
- Go is already discoverable through the Go module proxy.
- PHP has a GitHub release, but is not Composer-installable until the Packagist package is submitted.
- Python, JavaScript, Java, .NET, and Ruby publish jobs are waiting for GitHub environment approval.

Waiting publish jobs:

| SDK | Waiting Job |
| --- | --- |
| Python | https://github.com/clv/vectorizer-ai-python/actions/runs/26796477737 |
| TypeScript / JavaScript | https://github.com/clv/vectorizer-ai-js/actions/runs/26796477833 |
| Java | https://github.com/clv/vectorizer-ai-java/actions/runs/26796477798 |
| .NET | https://github.com/clv/vectorizer-ai-dotnet/actions/runs/26796477892 |
| Ruby | https://github.com/clv/vectorizer-ai-ruby/actions/runs/26796477976 |

## PyPI

Package: `vectorizer-ai-sdk`

Configure a pending trusted publisher:

- Owner: `clv`
- Repository name: `vectorizer-ai-python`
- Workflow filename: `publish.yml`
- Environment name: `pypi`

After setup, approve the waiting `pypi` GitHub environment job. It will publish the wheel and sdist for `vectorizer-ai-sdk` and then create the GitHub release.

## npm

Package: `@vectorizer-ai/sdk`

Create or configure the npm scope:

- Scope: `@vectorizer-ai`
- Package: `sdk`

Configure trusted publishing:

- GitHub owner: `clv`
- Repository: `vectorizer-ai-js`
- Workflow filename: `publish.yml`
- Environment name: `npm`
- Allowed action: `npm publish`

After setup, approve the waiting `npm` GitHub environment job.

## NuGet

Package: `Vectorizer.AI`

Configure NuGet trusted publishing for:

- Repository owner: `clv`
- Repository name: `vectorizer-ai-dotnet`
- Workflow filename: `publish.yml`
- Environment name: `nuget`

Set this GitHub Actions secret in `clv/vectorizer-ai-dotnet`:

- `NUGET_USER`: the NuGet account or organization name that will own `Vectorizer.AI`

After setup, approve the waiting `nuget` GitHub environment job.

## RubyGems

Gem: `vectorizer_ai`

Configure trusted publishing:

- Repository owner: `clv`
- Repository name: `vectorizer-ai-ruby`
- Workflow filename: `publish.yml`
- Environment name: `rubygems`

After setup, approve the waiting `rubygems` GitHub environment job.

## Maven Central

Coordinates: `ai.vectorizer:vectorizer-ai-java`

Create or verify the Maven Central namespace:

- Namespace: `ai.vectorizer`
- Domain ownership likely requires control of `vectorizer.ai` DNS.

Add these GitHub Actions secrets in `clv/vectorizer-ai-java`:

- `JRELEASER_MAVENCENTRAL_SONATYPE_USERNAME`
- `JRELEASER_MAVENCENTRAL_SONATYPE_PASSWORD`
- `JRELEASER_GPG_PUBLIC_KEY`
- `JRELEASER_GPG_SECRET_KEY`
- `JRELEASER_GPG_PASSPHRASE`

Generate a dedicated release-signing GPG key if there is no existing company publishing key. After namespace verification and secrets are configured, approve the waiting `maven-central` GitHub environment job.

## Packagist

Package: `vectorizer/ai`

Submit this repository:

- https://github.com/clv/vectorizer-ai-php

Configure GitHub synchronization so future tags are imported automatically. The `v1.0.0` GitHub release already exists; Packagist should ingest that tag once the package is submitted.

## Release Approval Order

1. Configure each registry entry.
2. Confirm the package name is owned by the correct account or organization.
3. Approve the matching waiting GitHub environment job.
4. Confirm the package appears in the registry.
5. Only then announce the SDK publicly.
