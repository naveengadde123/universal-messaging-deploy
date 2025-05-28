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

# Ensure nserverdaemon is executable
RUN chmod +x $UM_SERVER_HOME/bin/nserverdaemon

# Expose UM ports
EXPOSE 9900 9000

# Set working directory
WORKDIR $UM_SERVER_HOME/bin

# Start UM server
CMD ["./nserverdaemon", "console"]