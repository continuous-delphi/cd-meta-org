# Repository Lifecycle

This document defines the authoritative lifecycle model for repositories within the Continuous
Delphi organization. Lifecycle state is expressed via the repository maturity topic:

- `incubator`
- `stable`
- `deprecated

Lifecycle state is authoritative. Downstream consumers rely on it when making dependency decisions.

## 1. Incubator

Repositories under `cd-x-*` are incubator.

Characteristics:

- Concept and scope may evolve.
- Public API may change without notice.
- Breaking changes are permitted.
- Versioning remains `0.x.y`.
- No compatibility guarantees are provided.

Stable repositories must not depend on incubator repositories. Incubator status is temporary
by design.

## 2. Graduation to Stable

A repository may graduate from `cd-x-*` only when **all** of the following are true:

- [ ] CI is configured and passing on the primary branch.
- [ ] Builds are deterministic and reproducible.
- [ ] Documentation clearly defines scope and public API.
- [ ] The public API is not expected to change in breaking ways.
- [ ] The repository is consumed by at least one internal or reference repository.
- [ ] A stable release tag (`1.0.0` or higher) has been published.

Graduation steps:

1. Rename or move the repository under the appropriate stable domain prefix.
2. Assign the `stable` maturity topic.
3. Publish the first stable MAJOR release.
4. Announce the transition in `cd-meta-org`.

## 3. Stable

Stable repositories represent an organizational commitment. They must:

- Follow semantic versioning strictly.
- Maintain passing CI.
- Maintain deterministic builds.
- Provide migration guidance for MAJOR upgrades.
- Avoid introducing breaking changes without a MAJOR version increment.

If a stable repository cannot meet these obligations - for example, CI remains broken or a
breaking change is introduced without a MAJOR bump - it must be reviewed immediately. The
outcome must be either corrective action or transition to `deprecated`.

Stable status is not honorary; it is contractual.

## 4. Deprecation

A repository transitions to `deprecated` when a successor is identified or the project is no
longer strategically aligned.

Deprecation steps:

1. Assign the `deprecated` maturity topic.
2. Add a `DEPRECATED.md` explaining what replaces it and why.
3. Update the README to reflect deprecation status.
4. Archive the repository on GitHub.

Repositories are never deleted. History and context are preserved.

No new features may be introduced after deprecation.

## 5. Incubator Review and Expiry

Incubator repositories must not remain indefinitely without evaluation. If an incubator
repository shows no meaningful activity for six consecutive months, a lifecycle review is
required.

The review must result in one of:

- Graduation to `stable` (if all criteria are met).
- Continued incubator status with a defined roadmap.
- Transition to `deprecated` and archival.

## 6. Lifecycle Integrity

Lifecycle state is authoritative. Downstream consumers rely on it when making dependency
decisions. Repositories must not be labeled `stable` prematurely.

Incubator is temporary. Deprecated is final. Stable is a commitment.
