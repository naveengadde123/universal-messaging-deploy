FROM openjdk:11-jre-slim

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV UM_HOME=/opt/UniversalMessaging
ENV UM_SERVER_HOME=$UM_HOME/server/umserver
ENV PATH=$UM_SERVER_HOME/bin:$PATH

# Install necessary tools
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Copy Universal Messaging binaries into container
COPY UniversalMessaging/ $UM_HOME/

# Ensure nserverdaemon is executable
RUN chmod +x $UM_SERVER_HOME/bin/nserverdaemon

# Expose required ports
EXPOSE 9900 9001

# Set working directory to UM server
WORKDIR $UM_SERVER_HOME

# Default command to start UM in console mode
CMD ["./bin/nserverdaemon", "console"]
