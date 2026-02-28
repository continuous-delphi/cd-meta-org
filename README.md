# Continuous Delphi

`Continuous Delphi` is a practical modernization toolkit for teams maintaining long-lived Delphi systems.

It prioritizes disciplined, incremental modernization over risky rewrites and is intentionally structured to remain navigable as it scales.

Most repositories below are planned and may not yet exist. This document defines the architectural blueprint of the organization and will evolve as the ecosystem grows.

## How to use this organization

- Start with the Quick Links below to find the appropriate domain.
- Use the repository name prefixes to navigate the organization.
- Check each repository's topics to confirm its maturity before adopting it.

## Quick Links

GitHub Projects
  - [Continuous-Delphi Ecosystem Roadmap](https://github.com/orgs/continuous-delphi/projects/1)
    
Weekly Log entries
  - [Activity Logs](https://github.com/continuous-delphi/cd-meta-org/tree/main/logs/weekly)
    
Documentation and guidance repositories provide long-form guides and playbooks:
- [cd-doc-dev-setup](https://github.com/continuous-delphi/cd-doc-dev-setup) - Development environment setup guides for the Continuous Delphi organization.
- `cd-doc-playbook`
- `cd-doc-modernization-patterns`
- `cd-doc-ci-guide`

Standards and conventions repositories provide templates and shared configuration:
- `cd-std-style-guide`
- `cd-std-repo-template`
- `cd-std-gitattributes`
- `cd-std-editorconfig`

CI and DevOps repositories provide toolchains, actions, and pipeline templates:
- [cd-ci-toolchain](https://github.com/continuous-delphi/cd-ci-toolchain) - Delphi toolchain discovery and CI integration.
- `cd-ci-examples`
- `cd-ci-setup-delphi`
- `cd-ci-build-delphi`
- `cd-ci-run-dunitx`

Tooling repositories provide developer tools and CLIs:
- `cd-tool-radmake`
- `cd-tool-radfmt`
- `cd-tool-radlinter`
- `cd-tool-badges`

Library repositories provide reusable Delphi packages:
- `cd-lib-logging`
- `cd-lib-http`
- `cd-lib-json`

Reference implementation repositories demonstrate patterns and architecture:
- `cd-ref-dunitx-ci`
- `cd-ref-vcl-clean-architecture`
- `cd-ref-layered-monolith`

Specification repositories provide formal schemas and layout definitions:
- [cd-spec-delphi-compiler-versions](https://github.com/continuous-delphi/cd-spec-delphi-compiler-versions) - Canonical Delphi VER### mapping data (Delphi 2+) with aliases and toolchain metadata.
- `cd-spec-project-layout`
- `cd-spec-build-metadata`

Integration repositories connect Continuous Delphi tooling to third-party platforms:
- `cd-int-sonarqube`
- `cd-int-sigrid`

Security and compliance repositories cover SBOM, signing, and auditing:
- `cd-sec-sbom`
- `cd-sec-signing`

Packaging and distribution repositories support delivery to end users:
- `cd-pkg-getit-ready`
- `cd-pkg-winget`
- `cd-pkg-choco`

Incubator repositories are experimental prototypes using the `cd-x-*` prefix and are not considered stable.

## Organization naming taxonomy

This structure exists to prevent organizational entropy as the repository count grows.

| Prefix | Purpose |
|---|---|
| `cd-meta-*` | Org navigation and governance |
| `cd-doc-*` | Long-form guides and playbooks |
| `cd-std-*` | Standards and templates |
| `cd-ci-*` | CI tooling, actions, templates, examples |
| `cd-tool-*` | Developer tools and CLIs |
| `cd-lib-*` | Reusable Delphi libraries |
| `cd-ref-*` | Reference applications and patterns |
| `cd-spec-*` | Formal specs and schemas |
| `cd-int-*` | Third-party integrations |
| `cd-sec-*` | Security, SBOM, signing, compliance |
| `cd-pkg-*` | Packaging and distribution |
| `cd-x-*` | Incubator and prototypes |

For full details on topics, maturity labels, and pinning strategy, see [docs/org-taxonomy.md](docs/org-taxonomy.md).

## Maturity labels

All Repositories should be labeled with one of the following GitHub topics:

| Topic | Meaning |
|---|---|
| `incubator` | Experimental - subject to breaking change |
| `stable` | Intended for production use |
| `deprecated` | Kept for history; do not adopt |

## Contributing

- Prefer improvements that reduce friction for real Delphi teams.
- Keep solutions reproducible, deterministic, and CI-friendly.
- Follow the organization standards in `cd-std-*`.

See [CONTRIBUTING.md](CONTRIBUTING.md) when available.
