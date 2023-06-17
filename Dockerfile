FROM node:17-bullseye-slim AS chrono-build-stage
ENV NODE_ENV production
WORKDIR /usr/src/app

COPY client .

RUN npm ci --omit=dev && NODE_OPTIONS=--openssl-legacy-provider SKIP_PREFLIGHT_CHECK=true npm run build

# Deploy stage
FROM node:17-bullseye-slim
WORKDIR /usr/src/app

COPY --chown=node:node . .
RUN rm -rf client
RUN mkdir -p client/build
COPY --from=chrono-build-stage --chown=node:node /usr/src/app/build /usr/src/app/client/build

RUN apt-get update && apt-get install -y --no-install-recommends dumb-init && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN npm ci --omit=dev

USER node
CMD ["dumb-init", "npm", "run", "start"]
