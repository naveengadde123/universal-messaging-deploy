FROM openjdk:11-jre-slim

# Copy entire UM directory into container
COPY . /opt/um

# Set working directory to where nserverdaemon is actually located
WORKDIR /opt/um/UniversalMessaging/server/umserver/bin

# Set environment variables (if needed)
ENV JAVA_OPTS="-Xms256m -Xmx512m -verbose:gc"

# Start the server
CMD ["./nserverdaemon", "console"]
