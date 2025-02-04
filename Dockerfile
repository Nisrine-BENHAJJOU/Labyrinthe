FROM ubuntu:latest

# Install Wine and dependencies
RUN apt-get update && \
    apt-get install -y wine && \
    apt-get clean

# Set the working directory
WORKDIR /app

# Set the working directory
WORKDIR /app

# Copy the .exe file and any other required files
COPY Lab.exe .
COPY MSVCP140D.dll .
COPY MSWSOCK.dll .
COPY ucrtbased.dll .
COPY VCRUNTIME140D.dll .
COPY VCRUNTIME140_1D.dll .

# Expose the port your application uses (if applicable)
EXPOSE 8000

# Run the .exe file
CMD ["wine","Lab.exe"]
