# Use official Node.js runtime as base image
FROM node:18-alpine

# Set working directory in container
WORKDIR /usr/src/app

# Copy package files first to leverage Docker cache
COPY src/package*.json ./

# Install dependencies
RUN npm install

# Copy all application files
COPY src/ .

# Expose the application port (what your app listens on)
EXPOSE 80

# Command to run the application
CMD ["node", "app.js"]

