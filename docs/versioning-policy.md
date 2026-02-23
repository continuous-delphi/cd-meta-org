# Versioning Policy

This document defines versioning rules for all repositories within the Continuous Delphi organization.

These rules are mandatory for any repository marked as `stable`.

## 1. Semantic Versioning

All reusable tooling, libraries, and CI adapters follow semantic versioning:

```
MAJOR.MINOR.PATCH
```

- MAJOR: Incremented for breaking changes.
- MINOR: Incremented for backward-compatible feature additions.
- PATCH: Incremented for backward-compatible bug fixes.

Breaking changes must not be introduced under the same MAJOR version once a repository is marked `stable`.

Published version tags are immutable and must never be rewritten.

## 2. Stable Repositories

A repository marked `stable` must:

- Publish tagged releases.
- Follow semantic versioning strictly.
- Avoid breaking changes without incrementing MAJOR.
- Document migration steps when a MAJOR version is released.

Stable repositories are intended for downstream consumption and must behave predictably.

Version discipline is not optional - it is contractual.

## 3. Incubator Repositories

Repositories under `cd-x-*` use 0.x.y versioning.

- Breaking changes are allowed.
- APIs may evolve without migration guarantees.
- No compatibility promises are made.

Incubator repositories must not be depended upon by `stable` repositories.

A repository must not leave 0.x.y until it meets all graduation criteria defined in `docs/repo-lifecycle.md`.

## 4. GitHub Actions Versioning

GitHub Actions repositories must publish:

- Full release tags: vMAJOR.MINOR.PATCH
- Major alias tags: vMAJOR

Example:

````
v1.2.3   - immutable release tag
v1       - alias pointing to latest compatible v1.x.x release
````

Major alias tags must never be moved to incompatible code.

Breaking changes require publishing a new MAJOR tag (for example, v2). Consumers pin to the major alias tag to receive patches automatically.

## 5. Deprecation and Versioning

When a stable repository is deprecated:

- No new feature releases are published.
- Only security or data-loss fixes may increment PATCH after deprecation.
- The README must clearly indicate deprecation status.
- The repository may be archived once a replacement (if any) is established.

## 6. Pre-Release Identifiers

Pre-release identifiers (for example, -beta, -rc1) may be used prior to stable release.

Example:

````
1.0.0-beta1
1.0.0-rc1
````

Pre-release versions must not be used as major alias tags.

## 7. Documentation Repositories

Documentation repositories follow the same MAJOR.MINOR.PATCH structure once marked `stable`.

Tagging releases on documentation repositories is recommended once content is stable enough
to be referenced externally.

## 8. Policy Enforcement

Repositories marked `stable` that violate these rules must be corrected immediately. If
violations cannot be corrected, the repository must be reviewed for transition to `deprecated`
per the process defined in `docs/repo-lifecycle.md`.

Predictability is a core organizational principle. Version drift is not acceptable.
