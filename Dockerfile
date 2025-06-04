FROM openjdk:11-jre-slim

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV UM_HOME=/opt/UniversalMessaging
ENV UM_SERVER_HOME=$UM_HOME/server/umserver
ENV PATH=$UM_SERVER_HOME/bin:$PATH

RUN apt-get update && apt-get install -y \
    bash \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*

COPY UniversalMessaging $UM_HOME

RUN chmod +x $UM_SERVER_HOME/bin/nserverdaemon

EXPOSE 9900 9001

WORKDIR $UM_SERVER_HOME

CMD ["./bin/nserverdaemon", "console"]
