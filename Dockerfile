FROM openjdk:11-jre-slim

# Environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV UM_HOME=/home/vkraft/softwareAG3/UniversalMessaging
ENV UM_SERVER_HOME=$UM_HOME/server/umserver
ENV PATH=$UM_SERVER_HOME/bin:$PATH

# Install necessary tools
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p $UM_SERVER_HOME/bin $UM_SERVER_HOME/lib $UM_SERVER_HOME/data $UM_SERVER_HOME/logs

# Copy UM files (add this if you have UM binaries locally)
# COPY softwareAG3 /home/vkraft/softwareAG3/

# Add real UM startup script
COPY start-server.sh $UM_SERVER_HOME/bin/start-server.sh
RUN chmod +x $UM_SERVER_HOME/bin/start-server.sh

# Expose UM ports
EXPOSE 9900 9001

# Set working directory
WORKDIR $UM_SERVER_HOME

# Start the UM server
CMD ["./bin/start-server.sh"]