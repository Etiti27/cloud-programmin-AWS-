# Use an official Node.js runtime as the base image
FROM node:18

# Set the working directory in the container
WORKDIR /app/frontend

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

# Expose port 3000 (or any other port your app uses)
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]
