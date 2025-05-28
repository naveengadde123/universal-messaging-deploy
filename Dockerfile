FROM openjdk:11-jre-slim

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV UM_HOME=/opt/softwareAG/UniversalMessaging
ENV UM_SERVER_HOME=$UM_HOME/server/umserver
ENV PATH=$UM_SERVER_HOME/bin:$PATH

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    bash \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Create required directory
RUN mkdir -p /opt/softwareAG

# Copy contents into the image
COPY . /opt/softwareAG

# Expose UM ports
EXPOSE 9900 9000 9001

# Set working directory
WORKDIR $UM_SERVER_HOME/bin

# Start UM server
CMD ["./nserverdaemon", "console"]