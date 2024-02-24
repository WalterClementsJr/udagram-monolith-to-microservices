FROM beevelop/ionic:v2023.10.1
ENV NODE_OPTIONS=--openssl-legacy-provider
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci
COPY . .

RUN ionic build
CMD ionic serve --host 0.0.0.0 --port 80
