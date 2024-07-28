# Use the official Node.js 20 Alpine image
FROM node:20

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to WORKDIR
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application code to WORKDIR
COPY . .

# Expose the port that the app runs on
EXPOSE 8080

# Command to run the app
CMD ["npm", "start"]
