FROM node:18.19.1-slim

# add curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

# have nodemon available for local dev use (file watching)
RUN npm install -g nodemon

COPY package*.json ./

RUN npm ci && \
 npm cache clean --force && \
 mv /usr/local/app/node_modules /node_modules

COPY . .

# Secure the container by giving the built-in 'node' user ownership
RUN chown -R node:node /usr/local/app /node_modules
USER node

# Change to a non-privileged port
ENV PORT=8081
EXPOSE 8081

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
