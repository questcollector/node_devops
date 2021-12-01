# --- BASE ---
FROM node:lts-alpine AS base
RUN mkdir -p /node_devops/app
WORKDIR /node_devops/app
COPY package.json .
COPY yarn.lock .
COPY *.js .

# --- DEPENDENCIES ---
FROM base AS dependencies
RUN yarn install --production
RUN cp -R node_modules prod_node_modules
RUN yarn install

# --- TEST ---
FROM dependencies AS test
COPY --from=dependencies /node_devops/app/node_modules ./node_modules
COPY ./test ./test
RUN npm run test

# --- RELEASE ---
FROM base AS release
ARG NODE_ENV
ENV NODE_ENV=${NODE_ENV}
COPY --from=dependencies /node_devops/app/prod_node_modules ./node_modules
EXPOSE 3000
CMD ["sh", "-c", "npm run start:${NODE_ENV}"]
