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

RUN mkdir -p $UM_SERVER_HOME/bin $UM_SERVER_HOME/lib $UM_SERVER_HOME/data

RUN echo '#!/bin/bash\nset -e\necho "Placeholder UM startup"\nsleep infinity' > $UM_SERVER_HOME/bin/start-server.sh && \
    chmod +x $UM_SERVER_HOME/bin/start-server.sh

EXPOSE 9900 9001

WORKDIR $UM_SERVER_HOME

CMD ["./bin/start-server.sh"]