FROM openjdk:11-jre-slim

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV UM_HOME=/opt/softwareAG/UniversalMessaging
ENV UM_SERVER_HOME=$UM_HOME/server/umserver
ENV PATH=$UM_SERVER_HOME/bin:$PATH

RUN apt-get update && apt-get install -y \
    curl \
    bash \
    procps \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/softwareAG
COPY UniversalMessaging /opt/softwareAG/UniversalMessaging

# Ensure the script is executable
RUN chmod +x $UM_SERVER_HOME/bin/start-server.sh

WORKDIR $UM_SERVER_HOME/bin
EXPOSE 9900 9000 9001

CMD ["./start-server.sh"]
