# ─────────────────────────────────────────────────────────────────────────────
# Stage 1: Build
# Uses golang:1.26-alpine to match the module's Go 1.26.4 toolchain requirement.
# ─────────────────────────────────────────────────────────────────────────────
FROM golang:1.26-alpine AS builder

# Install git (needed by some go module fetches) and ca-certificates.
RUN apk add --no-cache git ca-certificates

WORKDIR /app

# Copy dependency manifests first for better layer caching.
# Subsequent builds only re-download modules when go.mod / go.sum change.
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code.
COPY . .

# Build a statically linked binary for the container's target architecture.
# CGO_ENABLED=0 produces a fully static binary (no libc dependency), which
# is safe here because none of the dependencies require cgo.
# GOOS=linux is required when building on Windows/macOS hosts.
# GOARCH is intentionally omitted so Docker BuildKit injects the target
# platform's architecture automatically (amd64, arm64, etc.).
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o server .

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2: Runtime
# Minimal Alpine image — no Go toolchain, no build tools.
# ─────────────────────────────────────────────────────────────────────────────
FROM alpine:3.21 AS runner

# Add trusted root certificates so the binary can make outbound HTTPS calls.
RUN apk add --no-cache ca-certificates

# Create a non-root user and group for security.
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy the statically compiled binary from the builder stage.
COPY --from=builder /app/server .

# Create runtime directories and give the non-root user write access.
RUN mkdir -p uploads outputs \
    && chown -R appuser:appgroup /app

# Switch to the non-root user.
USER appuser

# Expose the port the Go server listens on (see main.go: :8080).
EXPOSE 8080

# Healthcheck using the existing /api/health endpoint.
# --interval: how often Docker checks
# --timeout:  how long to wait for a response
# --retries:  consecutive failures before the container is marked unhealthy
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:8080/health || exit 1

# Start the compiled server.
ENTRYPOINT ["./server"]
