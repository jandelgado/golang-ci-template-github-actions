FROM gcr.io/distroless/static-debian12
ARG binary
LABEL maintainer="Jan Delgado <jdelgado@gmx.net>"

COPY $binary /app/
ENTRYPOINT ["/app/$binary"]