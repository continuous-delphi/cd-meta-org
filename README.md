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
- `cd-std-repo-template`
- `delphi-std-style-guide`
- `delphi-std-gitattributes`
- `delphi-std-editorconfig`

CI and DevOps repositories provide toolchains, actions, and pipeline templates:
- [delphi-toolchain-inspect](https://github.com/continuous-delphi/delphi-toolchain-inspect) - Delphi toolchain discovery and CI integration.
- `delphi-toolchain-test`
- `delphi-toolchain-build`
- `delphi-toolchain-deploy`
- `delphi-ci-examples`

Tooling repositories provide developer tools and CLIs:
- `delphi-tool-pasfmt`
- `delphi-tool-linter`
- `delphi-tool-badges`

Library repositories provide reusable Delphi packages:
- `delphi-lib-logging`
- `delphi-lib-http`
- `delphi-lib-json`

Reference implementation repositories demonstrate patterns and architecture:
- `delphi-ref-dunitx-ci`
- `delphi-ref-vcl-clean-architecture`
- `delphi-ref-layered-monolith`

Specification repositories provide formal schemas and layout definitions:
https://github.com/continuous-delphi/delphi-compiler-versions
- (delphi-compiler-versions)[https://github.com/continuous-delphi/delphi-compiler-versions) - Canonical Delphi VER### mapping data (Delphi 2+) with aliases and toolchain metadata.
- `delphi-project-layout`
- `delphi-build-metadata`

Integration repositories connect Continuous Delphi tooling to third-party platforms:
- `delphi-int-sonarqube`
- `delphi-int-sigrid`

Security and compliance repositories cover SBOM, signing, and auditing:
- `delphi-sec-sbom`
- `delphi-sec-signing`

Packaging and distribution repositories support delivery to end users:
- `delphi-pkg-getit-ready`
- `delphi-pkg-winget`
- `delphi-pkg-choco`

Incubator repositories are experimental prototypes using the `cd-x-*` prefix and are not considered stable.

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
