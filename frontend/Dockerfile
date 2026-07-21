# Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.* ./

RUN flutter pub get

COPY . .

ARG API_URL=http://localhost:3100
RUN flutter build web --release --dart-define=API_URL=$API_URL

# Serve with Nginx
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]