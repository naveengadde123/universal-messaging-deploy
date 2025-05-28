FROM openjdk:11-jre-slim
WORKDIR /opt/um
COPY . /opt/um
RUN chmod +x /opt/um/start-server.sh
CMD ["/opt/um/start-server.sh"]
