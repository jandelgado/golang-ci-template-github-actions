FROM golang:1.13 as build

WORKDIR /go/src/app
ADD . /go/src/app

RUN go get -u github.com/jandelgado/covfmt

#FROM gcr.io/distroless/base
FROM busybox:1.31

COPY --from=build /go/bin/covfmt /
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
