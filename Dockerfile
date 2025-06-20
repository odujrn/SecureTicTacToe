# Build stage
FROM node:20-alpine AS build
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source and build the app
COPY . .
RUN npm run build

# Production stage - Use a more recent nginx-alpine image
FROM nginx:1.25-alpine3.22

# Upgrade all packages to ensure latest security fixes
RUN apk update && apk upgrade --no-cache

# Copy built app from build stage to Nginx web root
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port and start Nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
