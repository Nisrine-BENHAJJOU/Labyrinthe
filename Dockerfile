FROM ubuntu:20.04

# Set timezone non-interactively to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y tzdata git wget curl unzip pkg-config g++ gcc build-essential cmake libboost-all-dev 

# Install vcpkg
RUN git clone https://github.com/microsoft/vcpkg.git /vcpkg
WORKDIR /vcpkg
RUN chmod +x ./bootstrap-vcpkg.sh && ./bootstrap-vcpkg.sh || cat bootstrap.log

# Install necessary libraries
RUN ./vcpkg install crow nlohmann-json

# Set environment variable for vcpkg
ENV VCPKG_ROOT=/vcpkg

# Copy your C++ project into the container
COPY . /app
WORKDIR /app

# Build your C++ project
RUN g++ -o main main.cpp -I/vcpkg/installed/x64-linux/include -L/vcpkg/installed/x64-linux/lib -lcrow -lnlohmann-json

# Expose the port your Crow app runs on
EXPOSE 8000

# Start the application
CMD ["./main"]
