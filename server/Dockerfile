# Server multiplayer de Pokémon Muia (Render, Docker).
# Va costruì dalla radice del repo:  docker build -f server/Dockerfile .
FROM node:22-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends ruby \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY server/package.json ./server/package.json
RUN cd server && npm install --omit=dev
COPY server/ponte.js server/muia_server.rb ./server/
# Solo i due file del plugin che el server dopra (cussì resta sempre uguale al zogo).
# Il nome de la cartela ga un apostrofo, che Docker no ciapa: se dopra l'asterisco.
COPY Plugins/Voltseon*/001_Base/001_VMS_Config.rb ./plugin/001_Base/
COPY Plugins/Voltseon*/006_Integrated_Server/001_VMS_Integrated_Server.rb ./plugin/006_Integrated_Server/
ENV NODE_ENV=production
EXPOSE 10000
CMD ["node", "server/ponte.js"]
