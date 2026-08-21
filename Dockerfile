FROM gcr.io/distroless/static-debian12
ARG TARGETPLATFORM
LABEL maintainer="Jan Delgado <jdelgado@gmx.net>"

COPY $TARGETPLATFORM/my-app /app
ENTRYPOINT ["/app"]