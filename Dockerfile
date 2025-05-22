# Stage 1: Build the application using Maven
FROM maven:3.9-eclipse-temurin-17 AS builder
# Use temurin-21 if your system.properties was for Java 21
# FROM maven:3.9-eclipse-temurin-21 AS builder

# Set the working directory in the container
WORKDIR /app

COPY .mvn/ .mvn/
COPY mvnw .
COPY mvnw.cmd .
COPY pom.xml .

RUN ./mvnw dependency:go-offline -B

# Copy the rest of your application's source code
COPY src ./src

# Package the application (skip tests for faster build in Docker)
# Ensure mvnw has execute permissions from your Git repo
RUN ./mvnw package -DskipTests -B

# Stage 2: Create the runtime image
# Use a JRE image that matches your build JDK version
FROM eclipse-temurin:17-jre-jammy
# Use temurin:21-jre-jammy if you built with Java 21
# FROM eclipse-temurin:21-jre-jammy

# Set the working directory
WORKDIR /app

# Define an argument for the JAR file name/path
ARG JAR_FILE_PATH=target/SpringAIProject-0.0.1-SNAPSHOT.jar

# Copy the JAR from the builder stage
COPY --from=builder /app/${JAR_FILE_PATH} app.jar

# Expose the port the application will run on (Spring Boot default is 8080)
# Render will override this with the PORT environment variable it injects.
EXPOSE 8080

# Set the entrypoint to run the application
# Spring Boot will listen on the PORT environment variable provided by Render.
ENTRYPOINT ["java", "-jar", "app.jar"]