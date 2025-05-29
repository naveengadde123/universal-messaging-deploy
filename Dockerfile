FROM openjdk:11-jre-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV UM_HOME=/opt/softwareAG/UniversalMessaging
ENV UM_SERVER_HOME=$UM_HOME/server/umserver
ENV PATH=$UM_SERVER_HOME/bin:$PATH

# Create UM directory
RUN mkdir -p $UM_SERVER_HOME

# Copy UM installation files into the correct directory
COPY UniversalMessaging $UM_HOME

# Ensure the start script is executable
RUN chmod +x $UM_SERVER_HOME/start-server.sh

# Expose necessary ports
EXPOSE 9900 9000

# Set working directory
WORKDIR $UM_SERVER_HOME

# Start UM server
CMD ["./start-server.sh"]
