FROM node:13-alpine as node-package

RUN apk update && apk add --no-cache make gcc g++ python bash git findutils
WORKDIR /app
COPY package.json .
COPY package-lock.json .
RUN npm ci -q

FROM node-package AS build

WORKDIR /app
COPY tsconfig.json tsconfig.json
COPY tslint.json tslint.json
COPY src src
RUN npm run build
RUN npm prune --production

FROM node:13-alpine

ENV NODE_ENV=production

WORKDIR /app
RUN apk update && apk add --no-cache bash curl
COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/dist /app/dist
COPY versions.json /app/versions.json
COPY package.json /app
COPY ormconfig.js /app

EXPOSE 3000
CMD npm start
