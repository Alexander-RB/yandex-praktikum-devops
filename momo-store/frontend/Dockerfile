FROM node:16.20.0-alpine3.18 AS builder
WORKDIR /app
COPY . .
ENV VUE_APP_API_URL=/
ENV NODE_ENV=/
RUN npm install 
RUN npm run build

FROM nginx:1.27.2-alpine-slim
WORKDIR /app
COPY --from=builder /app/dist /usr/share/nginx/html/
COPY default.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]
EXPOSE 80