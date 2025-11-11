FROM golang:1.24-alpine3.22 AS builder

ARG CGO_ENABLED=0
ARG VERSION

RUN apk --no-cache add git binutils

RUN git clone --depth=1 --branch=v${VERSION} https://github.com/coredns/coredns.git /coredns
WORKDIR /coredns
RUN go mod download

COPY --link ./ $GOPATH/pkg/mod/github.com/taonet-cloud/coredns
COPY plugin.cfg .

RUN go mod edit -replace github.com/taonet-cloud/coredns=$GOPATH/pkg/mod/github.com/taonet-cloud/coredns && \
    go generate coredns.go && \
    go build -mod=mod -o=/out/coredns && \
    strip -vs /out/coredns

FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=builder /out/coredns /coredns
USER nonroot:nonroot
# Reset the working directory inherited from the base image back to the expected default:
# https://github.com/coredns/coredns/issues/7009#issuecomment-3124851608
WORKDIR /
EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]