# Use a more specific Node.js base image
FROM node:18-slim

# Create app directory
WORKDIR /app

# Create a simple server file
RUN echo 'const http = require("http"); \
const server = http.createServer((req, res) => { \
  res.statusCode = 200; \
  res.setHeader("Content-Type", "text/plain"); \
  res.end("Docker Official Images Service Running"); \
}); \
const port = parseInt(process.env.PORT) || 8080; \
server.listen(port, "0.0.0.0", () => { \
  console.log(`Server running at http://0.0.0.0:${port}/`); \
});' > server.js

# Set environment variable for the port
ENV PORT=8080

# Expose the port
EXPOSE 8080

# Command to run the server
CMD ["node", "server.js"]
