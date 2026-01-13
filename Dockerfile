# Builder stage
FROM golang:1.23-alpine AS builder

# Install required build tools
RUN apk add --no-cache git make ca-certificates

WORKDIR /app

# Copy dependency definitions
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the binary statically
# CGO_ENABLED=0 ensures a static binary
ENV CGO_ENABLED=0
# We use make build to ensure all ldflags (version, commit, etc) are set correctly
RUN make build

# Runner stage
FROM scratch

# Copy CA certificates from builder (required for TLS)
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/mikrotik-exporter .

# Expose default port
EXPOSE 9436

# Set entrypoint
ENTRYPOINT ["./mikrotik-exporter"]
