FROM maven:3.6.2-jdk-11 as builder

#OLD
#COPY src /usr/src/app/src

#OLD
#COPY pom.xml /usr/src/app

#OLD
#RUN mvn -f /usr/src/app/pom.xml clean package

#NEW
# Create a working directory
WORKDIR /usr/src/app

#NEW
# Copy the application source code and pom.xml to the container
COPY src ./src
COPY pom.xml .

#NEW
# Manually specify the new Spring Boot version
ENV SPRING_BOOT_VERSION=2.6.14

#NEW
# Update the Spring Boot version in the pom.xml
RUN mvn org.codehaus.mojo:versions-maven-plugin:2.7:set -DnewVersion=${SPRING_BOOT_VERSION} && \
    mvn -f /usr/src/app/pom.xml clean package

FROM adoptopenjdk/openjdk11:latest as runtime

LABEL maintainer="gshipley@gmail.com"

EXPOSE 8080

COPY --from=builder /usr/src/app/target/wildwest-1.0.jar /usr/app/wildwest.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/usr/app/wildwest.jar"]
