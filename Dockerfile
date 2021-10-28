# example docker image for 
# https://github.com/jandelgado/golang-ci-template-github-actions/

FROM golang:1.17-alpine as builder
ARG version

WORKDIR /go/src/app
ADD . /go/src/app

RUN  CGO_ENABLED=0 \
       go build -ldflags "-s -w" -o app

FROM gcr.io/distroless/base-debian10
LABEL maintainer="Jan Delgado <jdelgado@gmx.net>"

COPY --from=builder /go/src/app/app /
ENTRYPOINT ["/app"]
