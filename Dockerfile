# Use an official C++ image
FROM gcc:latest

# Install dependencies
RUN apt-get update && apt-get install -y cmake libboost-all-dev 

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Build the project
RUN g++ -o server main.cpp -I ./include -lpthread -lboost_system 

# Expose the port your Crow app runs on
EXPOSE 8000

# Run the server
CMD ["./server"]
