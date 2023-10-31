FROM node:20.3.1
WORKDIR /tmp/app
COPY . ./
RUN npm install
USER node
CMD ["node", "--unhandled-rejections=strict", "./server.js"]
EXPOSE 8080
