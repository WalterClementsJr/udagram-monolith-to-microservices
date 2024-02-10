FROM beevelop/ionic:v2023.10.1 AS ionic
ENV NODE_OPTIONS=--openssl-legacy-provider
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci
COPY . .

RUN ionic build
FROM nginx:alpine
COPY --from=ionic /usr/src/app/www /usr/share/nginx/html
