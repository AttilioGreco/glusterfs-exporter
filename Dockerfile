FROM golang:alpine as build

# Otherwise make runs with /bin/sh
ENV SHELL "bash"

RUN apk add --update bash git curl make && \
    curl -sL https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64 > $GOPATH/bin/dep && \
    chmod 755 $GOPATH/bin/dep && \
    curl -sL https://github.com/alecthomas/gometalinter/releases/download/v2.0.11/gometalinter-2.0.11-linux-amd64.tar.gz | tar --strip-components=1 -zxf - -C $GOPATH/bin && \
    mkdir -p $GOPATH/src/github.com/gluster && \
    cd $GOPATH/src/github.com/gluster && \
    git clone https://github.com/gluster/gluster-prometheus.git && \
    cd gluster-prometheus && \
    bash -c "make" && \
    cp ./extras/conf/gluster-exporter.toml.sample /tmp/gluster-exporter.toml && \
    cp ./build/gluster-exporter /tmp/

FROM alpine:3.9

COPY --from=build /tmp/gluster-exporter /
COPY --from=build /tmp/gluster-exporter.toml /
ENTRYPOINT ["/gluster-exporter"]
CMD ["--help"]
