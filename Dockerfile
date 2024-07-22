# Stage 1: Build the Go binary
FROM golang:1.20-alpine AS builder

# Install git for fetching dependencies
RUN apk update && apk add --no-cache git

# Set the working directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code
COPY . .

# Build the Go binary
ARG ver
RUN go build -ldflags "-w -s -X main.GitCommit=${ver}" -o build/tonutils-storage cli/main.go

# Stage 2: Create the final image
FROM alpine:latest

# Set the working directory inside the container
WORKDIR /root/

# Copy the Go binary from the builder stage
COPY --from=builder /app/build/tonutils-storage .
EXPOSE 8192

# Command to run the binary
CMD ["/bin/sh", "-c", "./tonutils-storage"]
