# golang ci template using github actions

[![Build Status](https://github.com/jandelgado/golang-ci-template-github-actions/workflows/run%20tests/badge.svg)](https://github.com/jandelgado/golang-ci-template-github-actions/actions?workflow=run%20tests)
[![Coverage Status](https://coveralls.io/repos/github/jandelgado/golang-ci-template-github-actions/badge.svg?branch=master)](https://coveralls.io/github/jandelgado/golang-ci-template-github-actions?branch=master)

<!-- TOC -->

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Info](#info)
- [Go-Version](#go-version)
- [Dependabot](#dependabot)
- [Tool dependencies](#tool-dependencies)
- [Creating a release](#creating-a-release)
- [Linting & Test](#linting--test)
  - [Linter](#linter)
  - [Dockerfile linting](#dockerfile-linting)
  - [Test](#test)
  - [Build verification](#build-verification)
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
the repository.

Finally, a multi-platform (`linux/amd64` and `linux/arm64`) docker image is
built, which gets published to
[ghcr.io](https://github.com/jandelgado/golang-ci-template-github-actions/pkgs/container/golang-ci-template-github-actions).
Run it with

```console
$ docker run --rm  ghcr.io/jandelgado/golang-ci-template-github-actions:latest
hello, world!
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
locally uses the exact same golangci-lint version as the CI. The "run tests"
workflow reads the version straight out of `tools/go.mod` instead of
hardcoding it a second time. `tools/go.mod` is the single source of truth here.

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

The push of the new tag triggers the CI, which uses goreleaser with
[this configuration](.goreleaser.yml) to

- build multi-platform release artifacts
- create a new release
- upload the artifacts, which are then available on the [releases page](/jandelgado/golang-ci-template-github-actions/releases).

Finally, goreleaser builds a single multi-platform (`linux/amd64` +
`linux/arm64`) docker image directly, via [`dockers_v2`](.goreleaser.yml)
(the successor to the now-deprecated `dockers`/`docker_manifests` config, see
[goreleaser deprecations](https://goreleaser.com/deprecations/#dockers)),
published to
[ghcr.io](https://github.com/jandelgado/golang-ci-template-github-actions/pkgs/container/golang-ci-template-github-actions).

To run goreleaser locally, start the tool with `goreleaser build --snapshot --clean`
(see [Build verification](#build-verification) below for how this is also checked in CI).

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

### Dockerfile linting

[hadolint](https://github.com/hadolint/hadolint), run via
[hadolint-action](https://github.com/hadolint/hadolint-action), lints the
[Dockerfile](Dockerfile). Like golangci-lint above, findings are uploaded as
SARIF but `no-fail: true` keeps the build green regardless of findings.

### Test

We use the
[coveralls-github-action](https://github.com/coverallsapp/github-action) to
upload the golang coverage to coveralls.

Don't forget to enable `Leave comments (x)` in coveralls, under
`repo settings` > `pull request alerts`, so that the coveralls-action posts a comment
with the test coverage to affected pull requests:

### Build verification

Since the actual multi-platform docker build (see [Creating a
release](#creating-a-release)) can only run as part of a real
`goreleaser release`, the [`build`](.github/workflows/build.yml) workflow
instead runs `goreleaser build --snapshot --clean` on every push/PR as a fast,
docker-free smoke check that the code still cross-compiles for all
configured platforms, using the exact same build config as a real release.
The resulting binaries are uploaded as a `binaries` workflow artifact so they
can be downloaded and inspected without waiting for a release.

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
# just one version to remove; the gh CLI's default token lacks package
# scopes, so request them once)
$ gh auth refresh -h github.com -s read:packages,delete:packages
$ VERSION_ID=$(gh api /user/packages/container/golang-ci-template-github-actions/versions \
    --jq '.[] | select(.metadata.container.tags[]? == "v0.0.0-test") | .id')
$ gh api --method DELETE /user/packages/container/golang-ci-template-github-actions/versions/$VERSION_ID
```

![pr screenshot](images/pr.png)

## Author

(c) copyright 2021-2026 by Jan Delgado, License MIT
