# Build stage
FROM node:20-alpine AS build
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source and build the app
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine

# Fix vulnerabilities: upgrade libxml2 using --no-cache to avoid caching the index
RUN apk update && apk upgrade --no-cache libxml2

# Copy built app from build stage to Nginx web root
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port and start Nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
