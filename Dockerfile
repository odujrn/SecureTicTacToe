# Build stage
FROM node:20-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage: Custom nginx on alpine with fixed libxml2
FROM alpine:3.21

# Ensure Alpine uses correct repo mirrors, update package index,
# then install nginx and fixed libxml2 version explicitly
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.21/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.21/community" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache nginx libxml2=2.13.4-r6

# Verify libxml2 version (optional debugging step)
RUN apk info libxml2 | grep -q "2.13.4-r6" || (echo "Wrong libxml2 version installed!" && exit 1)

# Create nginx runtime directories
RUN mkdir -p /run/nginx /var/cache/nginx

# Copy built app from build stage to nginx web root
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]

