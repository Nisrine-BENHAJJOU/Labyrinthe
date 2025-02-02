FROM ubuntu:20.04

# Set the timezone non-interactively to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y tzdata

# Install required dependencies
RUN apt-get update && apt-get install -y cmake build-essential libboost-all-dev git wget curl unzip

# Clone vcpkg
RUN git clone https://github.com/Microsoft/vcpkg.git /vcpkg
WORKDIR /vcpkg

# Install additional dependencies for vcpkg before bootstrapping
RUN apt-get install -y pkg-config g++ gcc

# Bootstrap vcpkg
RUN ./bootstrap-vcpkg.sh

# Install the required libraries (Crow, nlohmann-json)
RUN ./vcpkg/vcpkg install crow nlohmann-json

# Set environment variable for vcpkg
ENV VCPKG_ROOT /vcpkg

# Copy your C++ project into the container
COPY . /app
WORKDIR /app

# Build your C++ project
RUN g++ -o main main.cpp -I/vcpkg/installed/x64-linux/include -L/vcpkg/installed/x64-linux/lib -lcrow -lnlohmann-json

# Expose the port your Crow app runs on
EXPOSE 8000

# Start the application
CMD ["./main"]
