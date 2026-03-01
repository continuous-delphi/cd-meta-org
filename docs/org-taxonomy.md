# Repository Taxonomy and Organization Strategy

This document defines how Continuous Delphi names, tags, and presents repositories so the
organization remains navigable at scale. It is the authoritative reference for anyone creating
a new repository or evaluating how the organization is structured.

## Purpose

This taxonomy keeps the Continuous Delphi organization readable, predictable, and scalable.
Repositories are locatable by domain without relying on GitHub UI features. The naming system
enforces disciplined incremental modernization and prevents the organization from degrading into
an unstructured collection of loosely related projects.

## Core naming rule

Every repository name follows the pattern:

```
cd-<domain>-<thing>
```

`cd` is the Continuous Delphi namespace. `domain` is one of the fixed categories defined below.
`thing` is a concise, kebab-case identifier describing the repository's purpose.

Examples:

- `cd-ci-toolchain`
- `cd-std-style-guide`
- `cd-ref-vcl-clean-architecture`

## Domain prefixes

The domain list is small and stable by design. Almost every repository fits one of these prefixes.
New domains require deliberate justification — see [When a repository does not fit any domain](#when-a-repository-does-not-fit-any-domain).

| Prefix       | Purpose                                                        |
|--------------|----------------------------------------------------------------|
| `cd-meta-*`  | Org navigation, governance, policies, indices                  |
| `cd-doc-*`   | Long-form documentation, guides, playbooks                     |
| `cd-std-*`   | Standards, templates, conventions                              |
| `cd-ci-*`    | CI tooling, GitHub Actions, CI templates, examples             |
| `cd-tool-*`  | Developer tools, CLIs, IDE plugins, utilities                  |
| `cd-lib-*`   | Reusable libraries intended for inclusion in projects          |
| `cd-ref-*`   | Reference implementations and canonical examples               |
| `cd-spec-*`  | Formal specifications, schemas, file formats                   |
| `cd-int-*`   | Integrations (SonarQube, Sigrid, Slack, etc.)                  |
| `cd-sec-*`   | Security, SBOM, signing, compliance                            |
| `cd-pkg-*`   | Packaging and distribution (GetIt, winget, choco)              |
| `cd-x-*`     | Incubator / prototypes — graduate to a stable domain later     |

### Naming guidance

The `<thing>` segment uses verbs for CI and action repositories (`setup`, `build`, `run`, `test`,
`package`) and nouns for library repositories (`logging`, `http`, `json`, `threading`). Reference
repositories use descriptive noun phrases identifying the architecture or pattern:
`vcl-clean-architecture`, `dunitx-ci`.

A repository with no stable release tag, or one still expected to introduce breaking changes,
belongs under `cd-x-*`. When in doubt, use `cd-x-*`.

## Topics

Topics are a secondary navigation layer that improves filtering and discovery. They do not replace
prefixes — a repository must be understandable by name alone.

### Mandatory topics (every repository)

- `continuous-delphi`
- `delphi` (omit only if the repository is genuinely Delphi-agnostic)

### Domain topic (exactly one per repository)

| Prefix       | Topic           |
|--------------|-----------------|
| `cd-meta-*`  | `meta`          |
| `cd-doc-*`   | `documentation` |
| `cd-std-*`   | `standards`     |
| `cd-ci-*`    | `ci`            |
| `cd-tool-*`  | `tooling`       |
| `cd-lib-*`   | `library`       |
| `cd-ref-*`   | `reference`     |
| `cd-spec-*`  | `spec`          |
| `cd-int-*`   | `integration`   |
| `cd-sec-*`   | `security`      |
| `cd-pkg-*`   | `packaging`     |
| `cd-x-*`     | `incubator`     |

### Platform and technology topics (0–5 per repository)

Add topics reflecting the technologies or platforms the repository targets. Examples:
`github-actions`, `gitlab`, `jenkins`, `msbuild`, `dunitx`, `vcl`, `fmx`, `windows`.

### Maturity topic (exactly one per repository)

Every repository carries exactly one of: `incubator`, `stable`, `deprecated`.

## Repository description tags

Every repository description begins with a bracketed domain marker, keeping the organization
list scannable without opening individual repositories.

| Domain       | Tag      |
|--------------|----------|
| `cd-meta-*`  | `[META]` |
| `cd-doc-*`   | `[DOC]`  |
| `cd-std-*`   | `[STD]`  |
| `cd-ci-*`    | `[CI]`   |
| `cd-tool-*`  | `[TOOL]` |
| `cd-lib-*`   | `[LIB]`  |
| `cd-ref-*`   | `[REF]`  |
| `cd-spec-*`  | `[SPEC]` |
| `cd-int-*`   | `[INT]`  |
| `cd-sec-*`   | `[SEC]`  |
| `cd-pkg-*`   | `[PKG]`  |
| `cd-x-*`     | `[X]`    |

Example:

```
[CI] Delphi toolchain discovery and MSBuild wrapper for deterministic CI builds.
```

## Archiving and deprecation

Experimental work lives in `cd-x-*`. When a prototype is abandoned or superseded:

1. Set its maturity topic to `deprecated`.
2. Archive the repository on GitHub.
3. Add a `DEPRECATED.md` to the repo root explaining what supersedes it and why.

Do not delete repositories. Preserve history and context.

## CI vendor adapters

GitHub Actions repositories use the `cd-ci-*` prefix. Other CI systems require dedicated adapter
repositories and must not use "actions" in their names:

- `cd-ci-gitlab-templates` — GitLab includes and templates
- `cd-ci-jenkins-library` — Jenkins Shared Library (Groovy)
- `cd-ci-azure-pipelines` — Azure Pipelines templates and examples

All CI adapters depend on `cd-ci-toolchain` as the shared core. Toolchain discovery and MSBuild
invocation logic is not duplicated across adapters.

## Versioning

Reusable tooling repositories follow semantic versioning. GitHub Actions publish stable major tags
(`v1`, `v2`) alongside full release tags. Consumers pin to the major tag to receive patches
automatically.

Breaking changes are never introduced under a stable major tag. When breaking changes are
necessary, bump the major version and document the migration path in the release notes.

## Repository creation checklist

Before creating a repository, confirm:

- [ ] Name follows `cd-<domain>-<thing>` with a valid domain prefix.
- [ ] Topics include `continuous-delphi`, `delphi` (if applicable), one domain topic, and one maturity topic.
- [ ] Description begins with the correct `[DOMAIN]` tag.
- [ ] README links back to `cd-meta-org` under a "Part of Continuous Delphi" section.
- [ ] Repository is under `cd-x-*` if it has no stable release tag or expects breaking changes.

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
dependencies (without having to parse the `.gitmodules` file)

Try to limit the number of submodules to the minimum necessary.

## When a repository does not fit any domain

If a repository does not clearly belong to an existing domain:

1. Place it temporarily under `cd-x-*`.
2. Open a discussion issue in `cd-meta-org` describing the proposed scope.
3. Reach maintainer consensus before introducing a new domain prefix.

New domain prefixes are rare by design. The prefix list must remain stable and memorable.

## Future evolution

Expand curated indices in `cd-meta-org` as the organization grows rather than relying on GitHub
organization page discovery. Domain prefixes change only with deliberate maintainer agreement.
Successful `cd-x-*` projects graduate into stable domains — the incubator is not a permanent home.

## Entity and schema naming

All `cd-spec-*` repositories MUST follow a consistent, org-wide convention for JSON schema and data modeling.
This prevents drift between specifications and ensures long-term interoperability across tooling, generators, and consumers.

### JSON property naming

- All JSON keys MUST use lowerCamelCase.
- Underscores (`snake_case`) MUST NOT be used in JSON keys.
- Acronyms are treated as words (for example: `utcDate`, `bdsRegVersion`, not `UTCDate` or `bds_reg_version`).
- Property names SHOULD use clear, descriptive terms over abbreviations unless the abbreviation is domain-standard
- Arrays MUST be used for collections (for example: aliases: []).

### Schema consistency

- JSON Schema property names MUST match the exact casing used in the corresponding data files.
- `$id` values MUST uniquely identify the file’s canonical URL.
- Versioned schemas (for example: schemas/1.0.0/...) MUST NOT share the same `$id` as unversioned “latest” schemas.
- Schema versions MUST follow semantic versioning.
- Breaking changes to property names or structure REQUIRE a schema version bump.

### Data semantics

- Dates MUST use ISO-8601 format.
- UTC timestamps SHOULD be explicit (for example: `2026-02-28T00:00:00Z`).
- Numeric values SHOULD be stored as numbers unless the value is an identifier
(for example: version strings like `"35.0"` may remain strings).

### Stability expectations

- Entity naming decisions are considered architectural.
Once a spec leaves incubator status, property names are treated as stable API surface.
- Spec repositories MUST NOT introduce mixed naming styles within the same schema.
- Any naming convention changes require explicit documentation in the changelog and appropriate version increments.

This standard applies to all `cd-spec-*` repositories and any future specification projects within the Continuous Delphi organization.
