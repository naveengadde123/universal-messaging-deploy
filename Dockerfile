FROM openjdk:11-jre-slim

# Create working directory
WORKDIR /opt/um

# Copy UM installation files
COPY . /opt/um

# Ensure the start script is executable
RUN chmod +x /opt/um/start-server.sh

# Optional: Expose the port Universal Messaging uses (default: 9900)
EXPOSE 9900

# Start the UM server
CMD ["./start-server.sh"]
