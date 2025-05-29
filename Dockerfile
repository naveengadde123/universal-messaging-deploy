FROM openjdk:11-jre-slim

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV UM_HOME=/home/vkraft/softwareAG3/UniversalMessaging
ENV UM_SERVER_HOME=$UM_HOME/server/umserver
ENV PATH=$UM_SERVER_HOME/bin:$PATH

RUN apt-get update && apt-get install -y \
    curl \
    bash \
    procps \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/vkraft/softwareAG3

COPY . /home/vkraft/softwareAG3

EXPOSE 9900 9000 9001

WORKDIR $UM_SERVER_HOME/bin

CMD ["./nserverdaemon", "console"]
