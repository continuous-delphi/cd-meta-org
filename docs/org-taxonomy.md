# Repository Taxonomy and Organization Strategy

This document defines how Continuous Delphi names, tags, and presents repositories so the
organization remains navigable at scale. It is the authoritative reference for anyone creating
a new repository or evaluating how the organization is structured.

## Purpose

This taxonomy keeps the Continuous Delphi organization readable, predictable, and scalable.
Repositories are locatable by domain without relying on GitHub UI features. The naming system
enforces disciplined incremental modernization and prevents the organization from degrading into
an unstructured collection of loosely related projects.

## Repository naming conventions

Repositories follow one of three naming conventions depending on their audience and purpose.

### Org infrastructure repositories -- `cd-*`

Repositories that exist to support the Continuous Delphi organization itself use the `cd-` prefix:

```
cd-<domain>-<thing>
```

`cd` is the Continuous Delphi namespace. `domain` is one of the fixed categories defined below.
`thing` is a concise, kebab-case identifier describing the repository's purpose.

Examples:

- `cd-meta-org`
- `cd-doc-dev-setup`

### Subject-matter repositories -- `delphi-*`

Repositories whose primary audience is Delphi developers -- tooling, specs, libraries, and
references -- use the `delphi-` prefix. The `continuous-delphi` org context already establishes
the organizational namespace; the `delphi-` prefix makes every repo immediately self-describing
to an outside reader without requiring familiarity with the `cd-` convention.

```
delphi-<domain>-<thing>
```

Examples:

- `delphi-compiler-versions` -- canonical Delphi compiler version dataset and spec
- `delphi-toolchain-inspect` -- version intelligence and installed compiler detection
- `delphi-toolchain-test` -- DUnitX and automated test execution tooling

### GitHub Actions marketplace repositories -- `action-delphi-*`

Repositories published to the GitHub Actions marketplace use the `action-delphi-` prefix.
This convention optimizes for marketplace discoverability while maintaining consistency with
the `delphi-*` subject-matter naming. Each action repo is a thin wrapper around the
corresponding toolchain repo -- business logic lives in the toolchain.

```
action-delphi-<thing>
```

Examples:

- `action-delphi-inspect` -- marketplace action wrapping `delphi-toolchain-inspect`
- `action-delphi-test` -- marketplace action wrapping `delphi-toolchain-test`

### Summary

| Audience / purpose                  | Convention            | Example                      |
|-------------------------------------|-----------------------|------------------------------|
| Org infrastructure and governance   | `cd-<domain>-<thing>` | `cd-meta-org`                |
| Subject-matter (tooling, specs)     | `delphi-<domain>-<thing>` | `delphi-toolchain-inspect` |
| GitHub Actions marketplace          | `action-delphi-<thing>` | `action-delphi-inspect`    |

## Domain prefixes

### `cd-*` domain prefixes

The domain list is small and stable by design. New domains require deliberate
justification -- see [When a repository does not fit any domain](#when-a-repository-does-not-fit-any-domain).

| Prefix       | Purpose                                                        |
|--------------|----------------------------------------------------------------|
| `cd-meta-*`  | Org navigation, governance, policies, indices                  |
| `cd-doc-*`   | Long-form documentation, guides, playbooks                     |

### `delphi-*` domain segments

| Segment            | Purpose                                                   |
|--------------------|-----------------------------------------------------------|
| `delphi-spec-*`    | Formal specifications, schemas, file formats              |
| `delphi-toolchain-*` | Developer tooling, CLIs, build and inspection scripts   |
| `delphi-lib-*`     | Reusable libraries intended for inclusion in projects     |
| `delphi-ref-*`     | Reference implementations and canonical examples          |
| `delphi-std-*`     | Standards, templates, conventions                         |
| `delphi-int-*`     | Integrations (SonarQube, Sigrid, Slack, etc.)             |
| `delphi-sec-*`     | Security, SBOM, signing, compliance                       |
| `delphi-pkg-*`     | Packaging and distribution (GetIt, winget, choco)         |
| `delphi-x-*`       | Incubator / prototypes -- graduate to a stable domain later |

### Naming guidance

The `<thing>` segment uses verbs for action repositories (`inspect`, `test`, `build`, `run`,
`package`) and nouns for library repositories (`logging`, `http`, `json`, `threading`).
Reference repositories use descriptive noun phrases identifying the architecture or pattern:
`vcl-clean-architecture`, `dunitx-ci`.

A repository with no stable release tag, or one still expected to introduce breaking changes,
belongs under `*-x-*`. When in doubt, use the incubator domain.

## Topics

Topics are a secondary navigation layer that improves filtering and discovery. They do not replace
prefixes -- a repository must be understandable by name alone.

### Mandatory topics (every repository)

- `continuous-delphi`
- `delphi` (omit only if the repository is genuinely Delphi-agnostic)

### Domain topic (exactly one per repository)

| Prefix / segment       | Topic           |
|------------------------|-----------------|
| `cd-meta-*`            | `meta`          |
| `cd-doc-*`             | `documentation` |
| `delphi-spec-*`        | `spec`          |
| `delphi-toolchain-*`   | `tooling`       |
| `delphi-lib-*`         | `library`       |
| `delphi-ref-*`         | `reference`     |
| `delphi-std-*`         | `standards`     |
| `delphi-int-*`         | `integration`   |
| `delphi-sec-*`         | `security`      |
| `delphi-pkg-*`         | `packaging`     |
| `delphi-x-*`           | `incubator`     |
| `action-delphi-*`      | `github-actions` |

### Platform and technology topics (0-5 per repository)

Add topics reflecting the technologies or platforms the repository targets. Examples:
`github-actions`, `gitlab`, `jenkins`, `msbuild`, `dunitx`, `vcl`, `fmx`, `windows`.

### Maturity topic (exactly one per repository)

Every repository carries exactly one of: `incubator`, `stable`, `deprecated`.

## Repository description tags

Every repository description begins with a bracketed domain marker, keeping the organization
list scannable without opening individual repositories.

| Prefix / segment       | Tag        |
|------------------------|------------|
| `cd-meta-*`            | `[META]`   |
| `cd-doc-*`             | `[DOC]`    |
| `delphi-spec-*`        | `[SPEC]`   |
| `delphi-toolchain-*`   | `[TOOL]`   |
| `delphi-lib-*`         | `[LIB]`    |
| `delphi-ref-*`         | `[REF]`    |
| `delphi-std-*`         | `[STD]`    |
| `delphi-int-*`         | `[INT]`    |
| `delphi-sec-*`         | `[SEC]`    |
| `delphi-pkg-*`         | `[PKG]`    |
| `delphi-x-*`           | `[X]`      |
| `action-delphi-*`      | `[ACTION]` |

Example:

```
[TOOL] Inspect installed Delphi compiler versions and resolve aliases for CI pipelines.
```

## Archiving and deprecation

Experimental work lives in `*-x-*`. When a prototype is abandoned or superseded:

1. Set its maturity topic to `deprecated`.
2. Archive the repository on GitHub.
3. Add a `DEPRECATED.md` to the repo root explaining what supersedes it and why.

Do not delete repositories. Preserve history and context.

## CI vendor adapters

GitHub Actions repositories follow the `action-delphi-*` convention and are published to the
GitHub Actions marketplace. Other CI systems require dedicated adapter repositories:

- `delphi-ci-gitlab-templates` -- GitLab includes and templates
- `delphi-ci-jenkins-library` -- Jenkins Shared Library (Groovy)
- `delphi-ci-azure-pipelines` -- Azure Pipelines templates and examples

All CI adapters depend on the appropriate `delphi-toolchain-*` repository as the shared core.
Toolchain discovery and build invocation logic is not duplicated across adapters.

## Versioning

Reusable tooling repositories follow semantic versioning. GitHub Actions publish stable major tags
(`v1`, `v2`) alongside full release tags. Consumers pin to the major tag to receive patches
automatically.

Breaking changes are never introduced under a stable major tag. When breaking changes are
necessary, bump the major version and document the migration path in the release notes.

## Repository creation checklist

Before creating a repository, confirm:

- [ ] Name follows the correct convention for its audience:
  - Org infrastructure: `cd-<domain>-<thing>`
  - Subject-matter: `delphi-<domain>-<thing>`
  - GitHub Actions marketplace: `action-delphi-<thing>`
- [ ] Topics include `continuous-delphi`, `delphi` (if applicable), one domain topic, and one
      maturity topic.
- [ ] Description begins with the correct `[DOMAIN]` tag.
- [ ] README links back to `cd-meta-org` under a "Part of Continuous Delphi" section.
- [ ] Repository uses the `*-x-*` incubator domain if it has no stable release tag or expects
      breaking changes.

## Repository structure conventions

### Root directory

The root directory must remain navigable at a glance. Limit top-level
entries to well-known categories. Avoid accumulating miscellaneous files
directly in root as the repository matures.

Expected root entries:

- `.github/` -- CI workflows and GitHub-specific configuration
- `.gitignore`
- `.gitmodules` -- present only if the repository has submodules
- `LICENSE`
- `README.md`
- `source/` -- all production source code
- `submodules/` -- present only if the repository has submodules (see below)
- `tests/` -- all test code, fixtures, and test runners

### Submodules

If a repository contains submodules, they must be located under a
`submodules/` directory at the repo root. Submodules should not be placed
directly in root. Why? Because the presence of `submodules/` serves as
an explicit visual signal to contributors that the repository has external
dependencies and its contents provide an immediate inventory of those
dependencies (without having to parse the `.gitmodules` file).

Try to limit the number of submodules to the minimum necessary.

## When a repository does not fit any domain

If a repository does not clearly belong to an existing domain:

1. Place it temporarily under the appropriate `*-x-*` incubator domain.
2. Open a discussion issue in `cd-meta-org` describing the proposed scope.
3. Reach maintainer consensus before introducing a new domain segment.

New domain segments are rare by design. The segment list must remain stable and memorable.

## Future evolution

Expand curated indices in `cd-meta-org` as the organization grows rather than relying on GitHub
organization page discovery. Domain segments change only with deliberate maintainer agreement.
Successful `*-x-*` projects graduate into stable domains -- the incubator is not a permanent home.

## Entity and schema naming

All specification and tooling repositories MUST follow a consistent, org-wide convention for
JSON schema and data modeling. This prevents drift between specifications and ensures long-term
interoperability across tooling, generators, and consumers.

### JSON property naming

- All JSON keys MUST use lowerCamelCase.
- Underscores (`snake_case`) MUST NOT be used in JSON keys.
- Acronyms are treated as words (for example: `utcDate`, `bdsRegVersion`, not `UTCDate` or
  `bds_reg_version`).
- Property names SHOULD use clear, descriptive terms over abbreviations unless the abbreviation
  is domain-standard.
- Arrays MUST be used for collections (for example: `aliases: []`).

### Schema consistency

- JSON Schema property names MUST match the exact casing used in the corresponding data files.
- `$id` values MUST uniquely identify the file's canonical URL.
- Versioned schemas (for example: `schemas/1.0.0/...`) MUST NOT share the same `$id` as
  unversioned "latest" schemas.
- Schema versions MUST follow semantic versioning.
- Breaking changes to property names or structure REQUIRE a schema version bump.

### Data semantics

- Dates MUST use ISO-8601 format.
- UTC timestamps SHOULD be explicit (for example: `2026-02-28T00:00:00Z`).
- Numeric values SHOULD be stored as numbers unless the value is an identifier
  (for example: version strings like `"35.0"` may remain strings).

### Stability expectations

- Entity naming decisions are considered architectural. Once a repository leaves incubator
  status, property names are treated as stable API surface.
- Repositories MUST NOT introduce mixed naming styles within the same schema.
- Any naming convention changes require explicit documentation in the changelog and appropriate
  version increments.

This standard applies to all specification and tooling repositories within the Continuous
Delphi organization.
