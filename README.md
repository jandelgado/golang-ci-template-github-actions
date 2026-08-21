# golang ci template using github actions

[![Build Status](https://github.com/jandelgado/golang-ci-template-github-actions/workflows/CI/badge.svg)](https://github.com/jandelgado/golang-ci-template-github-actions/actions?workflow=CI)
[![Coverage Status](https://coveralls.io/repos/github/jandelgado/golang-ci-template-github-actions/badge.svg?branch=master)](https://coveralls.io/github/jandelgado/golang-ci-template-github-actions?branch=master)

<!-- TOC -->

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Info](#info)
- [Go-Version](#go-version)
- [Dependabot](#dependabot)
- [Tool dependencies](#tool-dependencies)
- [Creating a release](#creating-a-release)
  - [Keeping master releasable](#keeping-master-releasable)
- [Linting & Test](#linting--test)
  - [Linter](#linter)
  - [Dockerfile linting](#dockerfile-linting)
  - [Go vulnerability check](#go-vulnerability-check)
  - [Test](#test)
  - [Build verification](#build-verification)
  - [Container image scanning](#container-image-scanning)
- [Testing the pipeline](#testing-the-pipeline)
- [Author](#author)

<!-- /TOC -->

## Info

This repository serves as a template for github-actions integrated Go projects.
It consists of a `hello, world!` like example in source file [main.go](main.go)
which gets compiled into the binary `my-app` using goreleaser. The CI is
configured to run
[golangci-linter](https://github.com/golangci/golangci-lint-action) on the code,
before the unit tests are executed. Test coverage is uploaded to coveralls.io.

[goreleaser](https://github.com/goreleaser/goreleaser) is used to create the
final multi-plattform assets, which are automatically uploaded to the
[release](https://github.com/jandelgado/golang-ci-template-github-actions/releases/latest).
The [release-process](#creating-a-release) is triggered by pushing a git tag to
the repository. One `goreleaser release` run produces everything: the
binaries, the release archives, the GitHub release itself and a multi-platform
(`linux/amd64` and `linux/arm64`) docker image, published to
[ghcr.io](https://github.com/jandelgado/golang-ci-template-github-actions/pkgs/container/golang-ci-template-github-actions).

Every push and pull request runs the same goreleaser config as a
[snapshot build](#build-verification), so build problems surface on the pull
request rather than during a release, and the resulting image is
[scanned for vulnerabilities](#container-image-scanning). Run the image with

```console
$ docker run --rm  ghcr.io/jandelgado/golang-ci-template-github-actions:latest
hello, world!
version: 1.2.3 (commit 83d653184ccad5d5a10bc01220dc54d44301e708)
```

## Go-Version

The Go version to use is configured in `go.mod` with the `toolchain` directive.
When building locally, set `GOTOOLCHAIN` to `auto` to automatically install
the configured toolchain (introduced with Go 1.21).

## Dependabot

We use [dependabot](https://docs.github.com/en/code-security/dependabot) to
both keep the Go dependencies as well as the used github action up-to-date.
The [configuration can be found here](.github/dependabot.yml). The
[`tools/go.mod`](tools/go.mod) submodule described below is tracked as its
own `gomod` entry, separate from the project's own dependencies.

## Tool dependencies

Development tools like [golangci-lint](https://github.com/golangci/golangci-lint)
are pinned via a `tool` directive in a separate [`tools/go.mod`](tools/go.mod),
rather than in the project's own `go.mod`. golangci-lint bundles dozens of
individual linters, each with their own dependencies and adding it as a tool
dependency of the main module would pull all of that into this project's
`go.sum` and force the project's minimum Go version up to whatever
golangci-lint requires internally, just to run a dev tool. See
[jvt.me: Using a separate Go module for your tools.go](https://www.jvt.me/posts/2024/09/30/go-tools-module/)
for the background on this pattern.

This also means running `go tool -modfile=tools/go.mod golangci-lint run`
locally uses the exact same golangci-lint version as the CI. The CI workflow
reads the version straight out of `tools/go.mod` instead of hardcoding it a
second time. `tools/go.mod` is the single source of truth here.

To update golangci-lint to a newer version, run from the repository root:

```console
$ go get -tool -modfile=tools/go.mod github.com/golangci/golangci-lint/v2/cmd/golangci-lint@vX.Y.Z
```

(Dependabot does not (yet) propose this update itself, see the note in
[`dependabot.yml`](.github/dependabot.yml))

Additional development-only tools with their own dependency trees like
e.g. [go-arch-lint](https://github.com/fe3dback/go-arch-lint) or
[oapi-codegen](https://github.com/oapi-codegen/oapi-codegen) should be
added the same way, as `tool` entries in `tools/go.mod`, to keep them out of
the project's own dependency graph.

## Creating a release

A new release is created by creating a git tag and pushing it, e.g.:

```console
$ git tag -a "v1.2.3" -m "this is release v1.2.3"
$ git push origin v1.2.3
```

The push of the new tag triggers
[upload_assets.yml](.github/workflows/upload_assets.yml), which runs
`goreleaser release --clean` with [this configuration](.goreleaser.yml) to

- build multi-platform release artifacts,
- create a new release with a changelog assembled from the git history,
- upload the artifacts, which are then available on the [releases page](/jandelgado/golang-ci-template-github-actions/releases),
- build a single multi-platform (`linux/amd64` + `linux/arm64`) docker image
  via [`dockers_v2`](.goreleaser.yml) (the successor to the now-deprecated
  `dockers`/`docker_manifests` config, see
  [goreleaser deprecations](https://goreleaser.com/deprecations/#dockers)) and
  push it to
  [ghcr.io](https://github.com/jandelgado/golang-ci-template-github-actions/pkgs/container/golang-ci-template-github-actions),
  tagged with the release tag, the commit and (for non-prereleases) `latest`.

Keeping all of this in goreleaser means the release workflow is one step, and
the same config is exercised on every pull request by the
[snapshot build](#build-verification). The workflow's only other job is to
[attest the image](#container-image-scanning) after goreleaser has pushed it.

The version and commit are compiled into the binary via `ldflags`, using
goreleaser's `{{.Version}}` rather than `{{.Tag}}`: for a release the two are
equivalent (`1.2.3` vs `v1.2.3`), but for a snapshot build `{{.Tag}}` resolves
to the *previous* release, which would make a snapshot binary claim to be a
version it isn't. `{{.Version}}` renders `1.2.4-next` there instead, and it is
the same value used for the `org.opencontainers.image.version` image label, so
the binary and the image it ships in always agree.

To run goreleaser locally, start the tool with `goreleaser build --snapshot --clean`
(see [Build verification](#build-verification) below for how this is also checked in CI).

### Keeping master releasable

Nothing in the release workflow re-checks the commit being tagged: pushing a
tag publishes, whether or not [`ci.yml`](.github/workflows/ci.yml) ever passed
for that commit. That is deliberate - the alternative is for the release
workflow to hunt down and wait for another workflow's run, which is a lot of
machinery to work around a problem that branch protection solves properly.

Configure the repository so that `master` is always releasable, under
`Settings` > `Branches` > branch protection rule for `master`:

- *Require a pull request before merging*
- *Require status checks to pass before merging*, selecting the `lint`,
  `test` and `build` checks from the CI workflow

Then every commit on `master` has already passed CI by the time it can be
tagged, and tagging a commit that is on `master` is safe by construction.
Tagging something that never went through a pull request is the one case this
does not cover, and is worth avoiding.

## Linting & Test

### Linter

[golangci-linter](https://github.com/golangci/golangci-lint-action) is
configured for code-linting. The report is uploaded so that linting results
are visible in the MR:

![pr screenshot](images/linter.png)

The workflow runs with `--issues-exit-code=0`, so lint findings are reported
but never fail the build. This is done here only so the demo (which
intentionally contains a lint finding) stays green. Remove that flag (or set
it to `1`) if you want linting to actually gate CI in your own project.

Run the linter locally with:

```console
$ go tool -modfile=tools/go.mod golangci-lint run
```

See [Tool dependencies](#tool-dependencies) for why golangci-lint is pinned
this way.

The same job also runs `go mod tidy -diff`, which *fails* if `go.mod` or
`go.sum` are not tidy. goreleaser deliberately has no `before` hook running
`go mod tidy`: a hook that rewrites the module during the build would let a
release be built from different dependencies than the ones committed, without
anyone noticing.

### Dockerfile linting

[hadolint](https://github.com/hadolint/hadolint), run via
[hadolint-action](https://github.com/hadolint/hadolint-action), lints the
[Dockerfile](Dockerfile). Like golangci-lint above, findings are uploaded as
SARIF but `no-fail: true` keeps the build green regardless of findings.

The base image is pinned by digest as well as by tag, the same way actions are
pinned by commit SHA: it keeps builds reproducible and gives the `docker`
entry in [`dependabot.yml`](.github/dependabot.yml) something to bump - an
unpinned `FROM` silently floats and dependabot has nothing to propose. The
`nonroot` variant is used, so the container runs as uid 65532 rather than root.

### Go vulnerability check

[govulncheck](https://go.dev/blog/vuln), run via
[govulncheck-action](https://github.com/golang/govulncheck-action), checks the
code against the Go vulnerability database. Unlike golangci-lint, it's
call-graph aware, so it only flags vulnerabilities in code paths actually
reached, not just anything present in `go.sum` - this complements Dependabot
(which just bumps dependency versions without checking reachability). It has
no SARIF output, so findings show up in the step log rather than the Security
tab. `continue-on-error: true` keeps the build green regardless of findings,
same reasoning as golangci-lint above.

### Test

We use the
[coveralls-github-action](https://github.com/coverallsapp/github-action) to
upload the golang coverage to coveralls.

Don't forget to enable `Leave comments (x)` in coveralls, under
`repo settings` > `pull request alerts`, so that the coveralls-action posts a comment
with the test coverage to affected pull requests:

### Build verification

Since the actual multi-platform docker build (see [Creating a
release](#creating-a-release)) only runs as part of a real `goreleaser
release`, the `build` job of [`ci.yml`](.github/workflows/ci.yml) runs
`goreleaser release --snapshot --clean --skip=docker` on every push/PR as a
fast smoke check that the code still cross-compiles for all configured
platforms (`linux`, `darwin`, `windows`, `freebsd`) and still packages
cleanly, using the exact same build config as a real release. The resulting
binaries are uploaded as a `binaries` workflow artifact so they can be
downloaded and inspected without waiting for a release.

The docker part is skipped there and handled by the next step instead:
goreleaser's multi-platform build can only write to the buildx cache when it
isn't pushing, and an image that exists only in the cache cannot be scanned.

### Container image scanning

To get a scannable image, the workflow stages the freshly built `linux/amd64`
binary the way [`dockers_v2`](.goreleaser.yml) would - as
`<os>/<arch>/my-app`, which is what the [Dockerfile](Dockerfile) copies from -
and builds that one platform locally:

```console
$ install -D dist/*_linux_amd64*/my-app dist/image-context/linux/amd64/my-app
$ docker buildx build --load --platform linux/amd64 \
    -f Dockerfile -t container-scan:local dist/image-context
```

This uses the same Dockerfile and the same context layout as a release, so it
also checks that the two still fit together. Scanning `linux/amd64` only is
enough here: the OS package CVEs of the shared distroless base don't differ by
architecture.

The image is then scanned with [Trivy](https://github.com/aquasecurity/trivy)
and the findings uploaded as SARIF to the Security tab, same non-blocking
pattern as golangci-lint/hadolint above. That upload is `continue-on-error`,
because fork pull requests get a read-only `GITHUB_TOKEN` regardless of the
workflow's `permissions:` block and may not write to the Security tab; the
findings still appear in the step log.

After a release, [upload_assets.yml](.github/workflows/upload_assets.yml)
attests the pushed image with GitHub's native [artifact
attestations](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations)
(`actions/attest-build-provenance`) - keyless Sigstore signing via the
workflow's own OIDC identity, no extra secrets or infrastructure. It shows up
under the package's "Attestations" tab on ghcr.io, so anyone pulling the image
can verify that this workflow actually built it:

```console
$ gh attestation verify oci://ghcr.io/jandelgado/golang-ci-template-github-actions:latest \
    --repo jandelgado/golang-ci-template-github-actions
```

The image also records where it came from in its
`org.opencontainers.image.revision`/`.version`/`.source` labels and index
annotations, and the binary prints its version and commit at startup.

## Testing the pipeline

To test the full release pipeline, including the actual multi-arch docker
build and push, push a pre-release tag, e.g. `v0.0.0-test`. Goreleaser
recognizes the semver pre-release suffix (the part after the `-`) and

- marks the created GitHub release as "pre-release" (`release.prerelease: auto`)
- skips updating the `latest` docker tag (the `latest` entry in `dockers_v2[].tags`
  is templated as `{{ if not .Prerelease }}latest{{ end }}`, so it renders empty
  and is dropped for pre-release tags)

both automatically, without needing any special-cased version number.

To revert everything a `v0.0.0-test` test release created either click through
the Github-UI or use these commands:

```console
# delete the GitHub release (keep the tag for now)
$ gh release delete v0.0.0-test --yes

# delete the git tag, locally and on the remote
$ git tag -d v0.0.0-test && git push origin :refs/tags/v0.0.0-test

# delete the matching docker image version from ghcr.io
# (dockers_v2 pushes a single multi-platform manifest per release, so there's
# just one version to remove; the attestation is pushed as its own version
# tagged "sha256-<digest of that manifest>" and can be removed the same way.
# The gh CLI's default token lacks package scopes, so request them once)
$ gh auth refresh -h github.com -s read:packages,delete:packages
$ VERSION_ID=$(gh api /user/packages/container/golang-ci-template-github-actions/versions \
    --jq '.[] | select(.metadata.container.tags[]? == "v0.0.0-test") | .id')
$ gh api --method DELETE /user/packages/container/golang-ci-template-github-actions/versions/$VERSION_ID
```

![pr screenshot](images/pr.png)

## Author

(c) copyright 2021-2026 by Jan Delgado, License MIT
