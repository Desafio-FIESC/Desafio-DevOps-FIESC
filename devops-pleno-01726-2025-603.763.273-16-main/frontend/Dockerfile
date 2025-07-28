# Etapa 1: build da aplicação
FROM node:18 as build

WORKDIR /app
COPY . .
RUN npm install && npm run build

# Etapa 2: usar nginx
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
