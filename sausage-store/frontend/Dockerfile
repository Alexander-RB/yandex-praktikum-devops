FROM node:16.20.0-alpine3.18 AS builder
WORKDIR /usr/src/app
COPY . .
RUN npm install 
RUN npm run build

# Шаг релиза
FROM nginx:latest
WORKDIR /app
COPY --from=builder /usr/src/app/dist/frontend /usr/share/nginx/html
COPY --from=builder /usr/src/app/nginx.tmpl /app/nginx.tmpl
EXPOSE 8080 