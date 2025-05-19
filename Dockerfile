FROM openjdk:11-jre-slim

# Add UM installation files
COPY . /opt/um

# Set environment variables or other setup as needed
WORKDIR /opt/um

# Define startup command
CMD ["./start-server.sh"]

