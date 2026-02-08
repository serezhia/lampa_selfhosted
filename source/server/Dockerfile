# Build Dart Frog
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Install dart_frog_cli
RUN dart pub global activate dart_frog_cli
ENV PATH="$PATH:/root/.pub-cache/bin"

COPY . .

# Generate Drift code
RUN dart run build_runner build --delete-conflicting-outputs

# Build the handler
RUN dart_frog build

# Compile the server binary from the build output
WORKDIR /app/build
RUN dart pub get
RUN mkdir -p /app/bin && dart compile exe bin/server.dart -o /app/bin/server

# Minimal runtime image
FROM debian:stable-slim

# Install CA certificates, SQLite library, and FFmpeg
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libsqlite3-0 \
    libsqlite3-dev \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/bin/server /app/bin/

# Create data directory for SQLite database
RUN mkdir -p /app/data && chmod 777 /app/data

# Create transcoding directory for HLS segments
RUN mkdir -p /app/transcoding && chmod 777 /app/transcoding

# Keep database.json for migration (will be moved to /app/data after first run)
RUN echo "{}" > /app/data/database.json && chmod 666 /app/data/database.json

EXPOSE 8080
CMD ["/app/bin/server"]
