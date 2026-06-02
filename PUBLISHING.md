# Publishing

This repository is the source of truth for regenerating the official Vectorizer.AI API SDKs from the public OpenAPI document.

## Release Process

1. Update the OpenAPI spec in the website/API repo.
2. Run `.\generate.ps1 -Version 1.0.1 -SpecUrl https://vectorizer.ai/api/openapi.json`.
3. Run `.\test.ps1 -Deep`.
4. Copy each generated `output/<language>` tree into the matching SDK repository.
5. Commit the generated SDK repo updates.
6. Tag each SDK repository with the same SemVer tag, for example `v1.0.1`. The tag must match the generated package version.
7. Let the per-language SDK repository publish through its own registry-native workflow.

The generated SDK repositories intentionally own their package-manager workflows. This keeps package provenance tied to the repository users install from.
