FROM ubuntu:20.04

# Set timezone non-interactively to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y tzdata git wget curl zip unzip tar pkg-config g++ gcc build-essential cmake libboost-all-dev 

# Clone and bootstrap vcpkg
RUN rm -rf /vcpkg
RUN git clone https://github.com/microsoft/vcpkg.git /vcpkg
WORKDIR /vcpkg
RUN chmod +x ./bootstrap-vcpkg.sh && ./bootstrap-vcpkg.sh

# Install necessary libraries
WORKDIR /vcpkg
RUN ./vcpkg install crow:x64-linux nlohmann-json:x64-linux

# Set environment variable for vcpkg
ENV VCPKG_ROOT=/vcpkg

# Copy your C++ project into the container
WORKDIR /app
COPY . .

# Verify if main.cpp exists
RUN ls -l /app

RUN ls -l /vcpkg/installed/
RUN ls -l /vcpkg/installed/x64-linux

# Build your C++ project
RUN g++ -o Lab Lab.cpp -I/vcpkg/installed/x64-linux/include

# Expose the port your Crow app runs on
EXPOSE 8000

# Start the application
CMD ["./Lab"]
