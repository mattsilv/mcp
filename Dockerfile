FROM node:22-bookworm-slim

ENV NODE_ENV=production

# Install dependencies for Puppeteer
RUN apt-get update && \
    apt-get install -y wget gnupg && \
    apt-get install -y fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 libcups2 libdbus-1-3 libgdk-pixbuf2.0-0 libgtk-3-0 libnspr4 libnss3 libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 libxss1 fonts-freefont-ttf libxshmfence1 && \
    apt-get clean

# Create app directory
WORKDIR /app

# Install MCP Puppeteer server
RUN npm install -g @modelcontextprotocol/server-puppeteer

# Run the server
ENTRYPOINT ["npx", "@modelcontextprotocol/server-puppeteer"] 