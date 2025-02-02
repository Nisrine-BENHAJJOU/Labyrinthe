FROM ubuntu:20.04

# Update and install necessary dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    build-essential \
    libboost-all-dev \
    git \
    wget

# Install vcpkg (C++ package manager)
RUN git clone https://github.com/Microsoft/vcpkg.git /vcpkg
WORKDIR /vcpkg
RUN ./bootstrap-vcpkg.sh

# Install the required libraries (Crow, nlohmann-json)
RUN ./vcpkg install crow nlohmann-json

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
CMD ./main
