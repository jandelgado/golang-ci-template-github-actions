# goreleaser stages the binaries it built as <os>/<arch>/my-app in the build
# context, matching buildx' TARGETPLATFORM, so one Dockerfile serves every
# platform in dockers_v2.platforms without compiling anything here.
#
# Pinned by digest as well as tag, like every other dependency in this repo:
# it makes the build reproducible and gives dependabot (see dependabot.yml,
# `package-ecosystem: docker`) something to bump. The `nonroot` variant runs
# as uid 65532 instead of root.
FROM gcr.io/distroless/static-debian12:nonroot@sha256:1b7b9f0f0e0a1d2155f531db587cc48ec26aaf97ab64364225f5bf18a054e66a
ARG TARGETPLATFORM
LABEL maintainer="Jan Delgado <jdelgado@gmx.net>"

COPY $TARGETPLATFORM/my-app /app
ENTRYPOINT ["/app"]
