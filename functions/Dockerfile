# Use the official Dart runtime as a parent image
FROM dart:stable AS build

# Set the working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Install dependencies
RUN dart pub get

# Copy the source code
COPY . .

# Compile the application
RUN dart compile exe bin/main.dart -o bin/server

# Build minimal serving image from AOT-compiled `/server`
FROM scratch

# Copy the compiled server from the build stage
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

# Expose port 8080
EXPOSE 8080

# Start the server
ENTRYPOINT ["/app/bin/server"]
