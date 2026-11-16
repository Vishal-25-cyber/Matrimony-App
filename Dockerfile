# Official Dart runtime image for building backend binary
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart compile exe bin/db_bridge.dart -o bin/server

# Lightweight runtime image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/bin/server /app/bin/server

EXPOSE 8080
ENV PORT=8080

CMD ["/app/bin/server"]
