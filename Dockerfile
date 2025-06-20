# Build stage
FROM node:20-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage: Custom nginx on alpine with fixed libxml2
FROM alpine:3.21

# Install nginx and the fixed libxml2 package
RUN apk update && apk add --no-cache nginx libxml2=2.13.4-r6

# Create nginx runtime dirs
RUN mkdir -p /run/nginx /var/cache/nginx

# Copy built app from build stage to nginx web root
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
