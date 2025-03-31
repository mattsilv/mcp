FROM --platform=linux/arm64 node:20-slim

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Install dependencies
RUN apt-get update && apt-get install -y \
    chromium \
    fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Install MCP Puppeteer server
RUN npm install -g @modelcontextprotocol/server-puppeteer

# Run the server
ENTRYPOINT ["npx", "@modelcontextprotocol/server-puppeteer"] 