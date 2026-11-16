# Stage 1: Build standalone Dart backend binary
FROM dart:stable AS build

WORKDIR /app

# Copy pure Dart backend dependencies
COPY pubspec.* ./
RUN dart pub get

# Copy backend source code and compile native server binary
COPY . .
RUN dart compile exe bin/db_bridge.dart -o bin/server

# Stage 2: Minimal runtime image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/bin/server /app/bin/server

EXPOSE 8080
ENV PORT=8080

CMD ["/app/bin/server"]
