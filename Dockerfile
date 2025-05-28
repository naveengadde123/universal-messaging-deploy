FROM openjdk:11-jre-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV UM_HOME=/home/vkraft/softwareAG3/UniversalMessaging
ENV UM_SERVER_HOME=$UM_HOME/server/umserver
ENV PATH=$UM_SERVER_HOME/bin:$PATH

# Create UM directory
RUN mkdir -p $UM_SERVER_HOME

# Copy UM installation files
COPY . $UM_SERVER_HOME

# Expose UM ports
EXPOSE 9900 9000

# Set working directory
WORKDIR $UM_SERVER_HOME

# Start UM server
CMD ["./start-server.sh"]