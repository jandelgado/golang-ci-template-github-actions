# note: we also need a running go executable in the container, so we keep
# this as the base 
FROM golang:1.13-alpine 

WORKDIR /go/src/app
ADD . /go/src/app

RUN GO111MODULE=on go get -u github.com/jandelgado/covfmt@fixing

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
