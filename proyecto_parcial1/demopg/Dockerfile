FROM openjdk:21-rc-oracle

LABEL maintainer="juzabrandon@hotmail.com"

VOLUME /tmp

EXPOSE 8080

ARG JAR_FILE=target/demopg-0.0.1-SNAPSHOT.jar
ADD ${JAR_FILE} antlr-api.jar

#RUN
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/antlr-api.jar"]
