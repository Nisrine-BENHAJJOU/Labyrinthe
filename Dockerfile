# Use a Windows Server Core base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

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
CMD ["Lab.exe"]
