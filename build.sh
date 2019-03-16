#!/bin/bash

useradd --create-home --shell /dev/null gradle
userdel -rf gradle

FROM pre-build AS build
ARG APP_JAR
RUN : ${APP_JAR:?No APP_JAR: Use --build-arg}
ARG GRADLE_VERSION
RUN : ${GRADLE_VERSION:?No GRADLE_VERSION: Use --build-arg}
RUN ["useradd", \
    "--create-home", \
    "--shell", "/dev/null", \
    "gradle"]
USER gradle:gradle
WORKDIR /home/gradle
# Avoid the "Welcome to Gradle" message
COPY --from=pre-build --chown=gradle:gradle \
    /tmp/release-features.rendered \
    .gradle/notifications/$GRADLE_VERSION/
COPY --chown=gradle:gradle ./ ./
RUN ["./gradlew", \
    "--console=rich", \
    "--no-daemon", \
    "--no-scan", \
    "--warn", \
    "wrapper"]
RUN ["./gradlew", \
    "--console=rich", \
    "--no-daemon", \
    "--no-scan", \
    "--warn", \
    "build"]
USER root:root
WORKDIR /
RUN ["rm", "/tmp/release-features.rendered"]
RUN cp /home/gradle/$APP_JAR /tmp/app.jar
RUN ["userdel", "-rf", "gradle"]

ARG JAVA_VERSION
FROM openjdk:${JAVA_VERSION}-jre-slim AS pre-run
RUN apt-get update \
    && apt-get install --yes \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# No default homedir files (like .bashrc)
RUN ["rm", "-rf", "/etc/skel"]
RUN ["useradd", \
    "--create-home", \
    "--shell", "/dev/null", \
    "app"]
USER app:app
WORKDIR /home/app
COPY --chown=app:app --from=build \
    /tmp/app.jar \
    ./
