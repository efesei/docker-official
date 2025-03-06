# Use Ubuntu as the base image
FROM ubuntu:latest

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      wget \
      git \
      gawk \
      bzip2 \
      jq \
      curl; \
    # Install Node.js (LTS version 18.x) so that npm is available
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -; \
    apt-get install -y nodejs; \
    rm -rf /var/lib/apt/lists/*

ENV DIR /usr/src/official-images
ENV BASHBREW_LIBRARY $DIR/library

# Copy the crane binary from the official container image
COPY --from=gcr.io/go-containerregistry/crane@sha256:fc86bcad43a000c2a1ca926a1e167db26c053cebc3fa5d14285c72773fb8c11d /ko-app/crane /usr/local/bin/

WORKDIR $DIR
COPY . $DIR

# Set environment variable for the port
ENV PORT 8080

# Expose port 8080 for Cloud Run routing
EXPOSE 8080

# Start the application using npm
CMD ["npm", "start"]
