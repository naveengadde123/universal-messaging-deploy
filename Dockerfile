FROM openjdk:11-jre-slim

# 1. Environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV UM_HOME=/home/vkraft/softwareAG3/UniversalMessaging
ENV UM_SERVER_HOME=$UM_HOME/server/umserver
ENV PATH=$UM_SERVER_HOME/bin:$PATH

# 2. Install needed tools
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*

# 3. Create only the directories UM cares about (data + logs)
RUN mkdir -p $UM_SERVER_HOME/data $UM_SERVER_HOME/logs

# 4. Copy the entire UM distribution into /home/vkraft/softwareAG3/
#    → 'softwareAG3' must exist in the same folder as this Dockerfile,
#      containing the full UniversalMessaging folder structure.
COPY softwareAG3 /home/vkraft/softwareAG3/

# 5. Ensure nserverdaemon.sh itself is executable
RUN chmod +x $UM_SERVER_HOME/bin/nserverdaemon.sh

# 6. Copy our wrapper script (start-server.sh) into the image
COPY start-server.sh $UM_SERVER_HOME/bin/start-server.sh
RUN chmod +x $UM_SERVER_HOME/bin/start-server.sh

# 7. Expose the ports UM uses
EXPOSE 9900 9001

# 8. Switch to the UM server directory
WORKDIR $UM_SERVER_HOME/bin

# 9. Launch the wrapper, which in turn exec's nserverdaemon.sh
#    (Your start-server.sh should contain something like:
#       #!/bin/bash
#       echo "[INFO] Starting Universal Messaging..."
#       exec ./nserverdaemon.sh console
#    )
CMD ["./start-server.sh"]
