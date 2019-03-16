# Error message 'invalid reference format' means you need to pass
# JAVA_VERSION=... and/or GRADLE_VERSION=... build args
ARG JAVA_VERSION
FROM openjdk:$JAVA_VERSION-jdk AS pre-gradle-setup
RUN apt-get update && apt-get install --yes && rm -rf /var/lib/apt/lists/*
# No default homedir files (like .bashrc)
RUN rm -rf /etc/skel
# Avoid the "Welcome to Gradle" message
RUN touch /tmp/release-features.rendered

FROM pre-gradle-setup AS gradle-setup
ARG GRADLE_VERSION
RUN : ${GRADLE_VERSION:?No GRADLE_VERSION: Use --build-arg or ./gradlew}
RUN useradd \
    --create-home \
    --shell /dev/null \
    gradle
USER gradle:gradle
WORKDIR /home/gradle
# Avoid the "Welcome to Gradle" message
COPY --from=pre-gradle-setup --chown=gradle:gradle \
    /tmp/release-features.rendered \
    .gradle/notifications/$GRADLE_VERSION/
COPY --chown=gradle:gradle \
    ./gradlew \
    ./
COPY --chown=gradle:gradle gradle/ gradle/
RUN ./gradlew wrapper \
    --gradle-version $GRADLE_VERSION \
    --distribution-type all

FROM gradle-setup AS java-build
USER gradle:gradle
WORKDIR /home/gradle
COPY --chown=gradle:gradle \
    build.gradle \
    gradle.properties \
    settings.gradle \
    ./
COPY --chown=gradle:gradle src/ src/
RUN ["./gradlew", \
    "--console=rich", \
    "--no-build-cache", \
    "--no-daemon", \
    "--no-scan", \
    "--warn", \
    "build"]

ARG JAVA_VERSION
FROM openjdk:$JAVA_VERSION-jre-slim AS pre-java-run
RUN apt-get update && apt-get install --yes
# No default homedir files (like .bashrc)
RUN rm -rf /etc/skel
RUN useradd \
    --create-home \
    --shell /dev/null \
    app

ARG JAVA_VERSION
FROM pre-java-run AS java-run
RUN apt-get update && apt-get install --yes
EXPOSE 8080
USER app:app
WORKDIR /home/app
COPY --chown=app:app --from=java-build \
    /home/gradle/build/libs/docker-java11-0-SNAPSHOT.jar \
    ./
CMD ["java", \
    "-jar", \
    "docker-java11-0-SNAPSHOT.jar"]
