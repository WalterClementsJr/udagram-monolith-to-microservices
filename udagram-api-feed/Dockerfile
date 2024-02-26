FROM node:14.21.3

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci
COPY . .

CMD [ "npm", "run", "prod" ]
