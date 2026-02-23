# Repository Creation Checklist

Use this checklist before creating a new repository in the Continuous Delphi organization.
It exists to prevent duplication, naming drift, and organizational entropy as the repository
count grows.

## 1. Confirm the repository is necessary

- [ ] Has this idea already been implemented elsewhere in the organization?
- [ ] Can this live inside an existing repository as a subfolder or module?
- [ ] Is this a stable enough concept to warrant its own repository?

If the concept is exploratory or experimental, use `cd-x-*` rather than claiming a stable
domain prefix prematurely.

## 2. Naming rules

Every repository name follows the pattern:

```
cd-<domain>-<thing>
```

### Approved domains

| Prefix       | Purpose                                          |
|--------------|--------------------------------------------------|
| `cd-meta-*`  | Organization navigation and governance           |
| `cd-doc-*`   | Documentation and guides                         |
| `cd-std-*`   | Standards and templates                          |
| `cd-ci-*`    | CI tooling, GitHub Actions, CI templates         |
| `cd-tool-*`  | Developer tools and utilities                    |
| `cd-lib-*`   | Reusable libraries                               |
| `cd-ref-*`   | Reference implementations                        |
| `cd-spec-*`  | Formal specifications                            |
| `cd-int-*`   | Third-party integrations                         |
| `cd-sec-*`   | Security and compliance                          |
| `cd-pkg-*`   | Packaging and distribution                       |
| `cd-x-*`     | Incubator / experimental                         |

### Naming conventions

- Use kebab-case only.
- Keep names short and concrete.
- Use verbs for CI and action repositories: `setup`, `build`, `run`, `test`, `package`.
- Use nouns for libraries: `logging`, `http`, `json`, `threading`.
- Avoid marketing names.
- Do not introduce new domain prefixes without a maintainer discussion in `cd-meta-org`.

## 3. Repository description

Every repository description begins with a bracketed domain marker:

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
[CI] Delphi toolchain discovery and MSBuild wrapper for deterministic builds.
```

## 4. Required topics

Every repository must include:

- `continuous-delphi`
- `delphi` (omit only if genuinely Delphi-agnostic)

Plus exactly one domain topic:

- `meta`, `documentation`, `standards`, `ci`, `tooling`, `library`, `reference`, `spec`,
  `integration`, `security`, `packaging`, or `incubator`

Plus exactly one maturity topic:

- `incubator`, `stable`, or `deprecated`

Plus zero to five platform or technology topics as applicable:

- `github-actions`, `gitlab`, `jenkins`, `msbuild`, `dunitx`, `vcl`, `fmx`, `windows`

## 5. README requirements

Every repository README must include:

- [ ] Clearly state its purpose and intended audience
- [ ] Maturity status (`incubator`, `stable`, `deprecated`)
- [ ] Basic usage example (if applicable)
- [ ] Backlink to `cd-meta-org` under a "Part of Continuous Delphi" section

Example footer:

```
Part of the Continuous Delphi modernization initiative.
See cd-meta-org for navigation and governance.
```

## 6. CI requirements

For repositories containing tooling or libraries:

- [ ] A CI workflow file exists at `.github/workflows/`.
- [ ] The build is deterministic and produces no environment-dependent output.
- [ ] The repository is not marked `stable` until CI is in place.

For GitHub Actions repositories specifically:

- [ ] Stable major tags (`v1`, `v2`) are published alongside full release tags.
- [ ] Breaking changes are never introduced under a stable major tag — bump the major version instead.

## 7. Incubator rules (`cd-x-*`)

Use `cd-x-*` when the API is unstable, the design is experimental, or long-term viability is
unknown. Incubator repositories must not be depended upon by stable repositories.

**Graduation process:**

1. Rename the repository with the correct stable domain prefix.
2. Update the domain topic and change the maturity topic from `incubator` to `stable`.
3. Ensure CI is in place and a stable release tag exists.
4. Announce the graduation in `cd-meta-org`.

## 8. Deprecation rules

When a repository is superseded:

1. Set its maturity topic to `deprecated`.
2. Add a `DEPRECATED.md` to the repository root explaining what replaces it and why.
3. Update the README with a link to the replacement.
4. Archive the repository on GitHub.

Do not delete repositories. Preserve history and context.

## 9. Final check — before clicking "Create Repository"

- [ ] Name follows `cd-<domain>-<thing>` with an approved domain prefix.
- [ ] Description begins with the correct `[DOMAIN]` tag.
- [ ] Required topics are set: mandatory, domain, and maturity.
- [ ] README includes purpose, maturity status, and backlink to `cd-meta-org`.
- [ ] CI workflow is defined (or documented as a known gap for incubator repos).
- [ ] Confirmed no existing repository already covers this scope.

If any item is unclear, open a discussion in `cd-meta-org` before proceeding.

---

*Structure today prevents chaos tomorrow.*
