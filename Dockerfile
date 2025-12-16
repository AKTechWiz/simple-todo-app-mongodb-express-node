# Use official Node.js runtime as base image
FROM node:14-alpine

# Set working directory in container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application code
COPY . .

# Expose port 5000 (default port for this app)
EXPOSE 5000

# Set environment variable for MongoDB connection
ENV MONGODB_URI=mongodb://mongodb:27017/tododb-dev

# Start the application
CMD ["npm", "start"]
