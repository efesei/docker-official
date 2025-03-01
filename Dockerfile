# FYI, this base image is built via ".github/workflows/.bashbrew/action.yml" (from https://github.com/docker-library/bashbrew/tree/master/Dockerfile)
FROM ubuntu:latest

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
# wget for downloading files (especially in tests, which run in this environment)
		ca-certificates \
		wget \
# git for cloning source code
		git \
# gawk for diff-pr.sh
		gawk \
# tar -tf in diff-pr.sh
		bzip2 \
# jq for diff-pr.sh
		jq \
	; \
	rm -rf /var/lib/apt/lists/*

ENV DIR /usr/src/official-images
ENV BASHBREW_LIBRARY $DIR/library

# crane for diff-pr.sh
# https://gcr.io/go-containerregistry/crane:latest
# https://explore.ggcr.dev/?image=gcr.io/go-containerregistry/crane:latest
COPY --from=gcr.io/go-containerregistry/crane@sha256:fc86bcad43a000c2a1ca926a1e167db26c053cebc3fa5d14285c72773fb8c11d /ko-app/crane /usr/local/bin/

WORKDIR $DIR
COPY . $DIR

# Install Python for a simple web server
RUN apt-get update && apt-get install -y python3

# Create a simple index.html file
RUN mkdir -p /app/public
WORKDIR /app/public
RUN echo "<html><body><h1>Docker Official Images Tools</h1><p>Container is running</p></body></html>" > index.html

# Set working directory back to original
WORKDIR $DIR

# Expose the port
EXPOSE 8080

# Start a simple HTTP server that listens on all interfaces (0.0.0.0) on port 8080
CMD cd /app/public && python3 -m http.server ${PORT:-8080} --bind 0.0.0.0
