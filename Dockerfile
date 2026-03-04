FROM node:18

RUN apt-get update && apt-get install -yqq --no-install-recommends \
    build-essential git

WORKDIR /home/node
USER node

COPY --chown=node:node package*.json ./
RUN npm install && npm install grunt-cli --save-dev
COPY --chown=node:node . ./
RUN npx grunt

CMD ["npm", "start"]
