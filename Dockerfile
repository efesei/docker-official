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
ENV PORT=8080

# Expose port 8080 for Cloud Run routing
EXPOSE 8080

# Create a simple HTTP server file with explicit binding to 0.0.0.0
RUN echo 'const http = require("http");\n\
const port = parseInt(process.env.PORT) || 8080;\n\
\n\
const server = http.createServer((req, res) => {\n\
  res.statusCode = 200;\n\
  res.setHeader("Content-Type", "text/plain");\n\
  res.end("Docker Official Images Service Running");\n\
});\n\
\n\
server.listen(port, "0.0.0.0", () => {\n\
  console.log(`Server running at http://0.0.0.0:${port}/`);\n\
});\n' > server.js

# Make sure server.js is executable
RUN chmod +x server.js

# Start the HTTP server
CMD ["node", "server.js"]
