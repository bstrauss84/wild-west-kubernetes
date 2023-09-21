# Use an official Maven image as the builder
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
#ARG SPRING_BOOT_VERSION=2.6.14

#LESSNEW
# Update the Spring Boot version in the pom.xml
#RUN mvn org.codehaus.mojo:versions-maven-plugin:2.7:set -DnewVersion=${SPRING_BOOT_VERSION} && \
#    mvn -f /usr/src/app/pom.xml clean package

#NEW
# Update the Spring Boot version in the pom.xml
#RUN sed -i "/<parent>/,/<\/parent>/ { /<version>/ s/<version>.*<\/version>/<version>${SPRING_BOOT_VERSION}<\/version>/ }" pom.xml && \
#    mvn clean package

#NEWER
RUN mvn -f pom.xml clean package -U

# Use an official OpenJDK 11 image as the runtime image
FROM adoptopenjdk/openjdk11:latest as runtime

# Set a maintainer label
LABEL maintainer="gshipley@gmail.com"

#STAGE TRIGGER UID 0 POLICY#
# Add a user with a non-root UID (e.g., UID 1000)
#RUN adduser -u 1000 --disabled-password myuser

# Switch to the non-root user
#USER myuser
#STAGE TRIGGER UID 0 POLICY#

# Expose the application port
EXPOSE 8080

#TRIGGER UID 0 POLICY#
# Run a command as root to trigger the ACS policy alert (during image build)
#USER root
#RUN whoami
#TRIGGER UID 0 POLICY#

#CLEANUP TRIGGER UID 0 POLICY#
# Switch back to the non-root user
#USER myuser
#CLEANUP TRIGGER UID 0 POLICY#

# Create a directory in the runtime image
RUN mkdir -p /usr/app

# Copy the JAR file from the builder stage to the runtime image
COPY --from=builder /usr/src/app/target/wildwest-1.0.jar /usr/app/wildwest.jar

# Define the entry point for running the application
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/usr/app/wildwest.jar"]

#TRIGGER UID 0 POLICY#
# Run a command as root to trigger the ACS policy alert (during image build)
# USER root
# RUN whoami
#TRIGGER UID 0 POLICY#

#REMOVE TO TRIGGER UBUNTU PACKAGE MANAGER FOUND IN IMAGE POLICY
# Remove package managers (apt and dpkg)
RUN apt-get update && apt-get -y remove --purge apt dpkg && apt-get clean

# Remove package manager cache to reduce image size
RUN rm -rf /var/lib/apt/lists/*
