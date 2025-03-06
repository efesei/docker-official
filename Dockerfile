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

# Copy your application files
COPY . $DIR

# Set environment variable for the port
ENV PORT 8080

# Expose port 8080 for Cloud Run routing
EXPOSE 8080

# Make sure npm dependencies are installed
RUN npm install

# Start the application using npm
# Adding a check to verify the package.json has a start script
RUN if ! grep -q '"start"' package.json; then \
      echo '{"scripts":{"start":"node server.js"}}' > package.json; \
    fi

# Create a basic server.js file if it doesn't exist
RUN if [ ! -f server.js ]; then \
      echo 'const http = require("http"); \
      const server = http.createServer((req, res) => { \
        res.statusCode = 200; \
        res.setHeader("Content-Type", "text/plain"); \
        res.end("Hello World"); \
      }); \
      const port = process.env.PORT || 8080; \
      server.listen(port, () => { \
        console.log(`Server running on port ${port}`); \
      });' > server.js; \
    fi

CMD ["npm", "start"]
