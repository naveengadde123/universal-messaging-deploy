FROM openjdk:11-jre-slim

# Copy the entire local directory (context) into /opt/um inside container
COPY . /opt/um

# Set working directory where nserverdaemon executable is located
WORKDIR /opt/um/UniversalMessaging/server/umserver/bin

# (Optional) Set Java options environment variable if your UM needs it
ENV JAVA_OPTS="-Xms256m -Xmx512m -verbose:gc"

# Run the nserverdaemon executable with 'console' argument
CMD ["./nserverdaemon", "console"]
