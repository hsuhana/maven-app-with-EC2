FROM amazoncorretto:8-alpine3.17-jre

EXPOSE 8080

WORKDIR /usr/app
COPY ./target/app.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]