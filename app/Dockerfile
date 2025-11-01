
# ---- Build stage ----
FROM node:20-alpine AS build
WORKDIR /app
# Install prod deps only (no dev)
COPY package.json package-lock.json* ./
RUN npm ci --only=production || npm install --omit=dev
# Copy app
COPY index.js ./

# ---- Runtime stage ----
FROM node:20-alpine
ENV NODE_ENV=production
WORKDIR /app

# Create non-root user/group
RUN addgroup -S nodegrp && adduser -S nodeusr -G nodegrp

# Copy only necessary artifacts from build
COPY --from=build /app /app

# Drop privileges
USER nodeusr

EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD wget -qO- http://127.0.0.1:3000/health || exit 1
CMD ["node", "index.js"]
