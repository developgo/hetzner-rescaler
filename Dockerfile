FROM golang:1.17.0-bullseye AS builder
WORKDIR /build

ARG TARGETOS
ARG TARGETARCH

COPY . .

# Create statically linked server binary
RUN CGO_ENABLED=0 && GOOS=${TARGETOS} && GOARCH=${TARGETARCH} && go build -x -mod vendor -tags netgo -ldflags '-w -extldflags "-static"' -o ./bin/hetzner-rescaler ./main.go

FROM scratch AS runner
WORKDIR /

COPY --from=builder /build/bin/hetzner-rescaler /bin/hetzner-rescaler
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

CMD ["hetzner-rescaler", "start", "-s"]