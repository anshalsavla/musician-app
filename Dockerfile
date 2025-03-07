# Use the official lightweight Node.js image from the Docker Hub
FROM node:14-alpine

# Create and change to the app directory
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY client/ client/
COPY models/ models/
COPY routes/ routes/
COPY public/ public/
COPY store/ store/
COPY app.js ./

# Expose the port the app runs on
EXPOSE 3000

# Define the command to run the app
CMD ["node", "/app/app.js"]