# Use an official OpenJDK runtime as a parent image
FROM openjdk:11-jdk-slim

# Set the working directory
WORKDIR /usr/src/app

# Install wget
RUN apt-get update && apt-get install -y wget
RUN apt-get install -y javacc

# Set the entrypoint to the JavaCC script
ENTRYPOINT ["/bin/bash"]

