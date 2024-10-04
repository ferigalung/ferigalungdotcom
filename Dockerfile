FROM node:lts-alpine AS build
WORKDIR /app

COPY . .

RUN npm install
RUN npm run build

FROM nginx:1.27.2-alpine

COPY --from=build /app/nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist /usr/share/nginx/html/