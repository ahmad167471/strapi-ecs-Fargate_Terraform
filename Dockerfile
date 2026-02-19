FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Build admin panel
RUN npm run build

ENV NODE_ENV=production

EXPOSE 1337

CMD ["npm", "start"]