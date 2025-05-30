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

COPY UniversalMessaging $UM_HOME

RUN if [ -f "$UM_SERVER_HOME/bin/start-server.sh" ]; then chmod +x "$UM_SERVER_HOME/bin/start-server.sh"; else echo '#!/bin/bash\nset -e\ncd $UM_SERVER_HOME/bin\nexec java $JAVA_OPTS -jar ../lib/nirvana.jar -config nserver.conf' > $UM_SERVER_HOME/bin/start-server.sh && chmod +x $UM_SERVER_HOME/bin/start-server.sh; fi

EXPOSE 9900 9000

WORKDIR $UM_SERVER_HOME

CMD ["./bin/start-server.sh"]