FROM openjdk:11-jre-slim
WORKDIR /opt/um
COPY . /opt/um
RUN chmod +x /opt/um/scripts/start-server.sh
CMD ["/opt/um/scripts/start-server.sh"]
