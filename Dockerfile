FROM openjdk:11-jre-slim

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV UM_HOME=/home/vkraft/softwareAG3/UniversalMessaging
ENV UM_SERVER_HOME=$UM_HOME/server/umserver
ENV PATH=$UM_SERVER_HOME/bin:$PATH

RUN apt-get update && apt-get install -y \
    bash \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Copy the entire UniversalMessaging directory into the image
COPY ./home/vkraft/softwareAG3/UniversalMessaging $UM_HOME

EXPOSE 9900 9001

WORKDIR $UM_SERVER_HOME

# Run the actual server daemon binary - update this command if needed
CMD ["./bin/nserverdaemon", "console"]
