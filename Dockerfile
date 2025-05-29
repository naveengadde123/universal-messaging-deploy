FROM openjdk:11-jre-slim

# Copy only the relevant UniversalMessaging directory into the expected path
COPY softwareAG3/UniversalMessaging /opt/um/UniversalMessaging

# Ensure the binary is executable
RUN chmod +x /opt/um/UniversalMessaging/server/umserver/bin/nserverdaemon

# Set the working directory to where the UM server binary is
WORKDIR /opt/um/UniversalMessaging/server/umserver/bin

# Set Java options environment variable
ENV JAVA_OPTS="-Xms256m -Xmx512m -verbose:gc"

# Run the nserverdaemon with 'console' argument
CMD ["./nserverdaemon", "console"]
