FROM openjdk:11-jre-slim

WORKDIR /opt/um

COPY . .

RUN chmod +x start-server.sh

CMD ["./start-server.sh"]
