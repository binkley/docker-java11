FROM gradle:5.1-jdk11 AS java-pre-build
RUN touch /tmp/release-features.rendered

FROM gradle:5.1-jdk11 AS java-build
WORKDIR /home/gradle
COPY --from=java-pre-build --chown=gradle:gradle \
    /tmp/release-features.rendered \
    .gradle/notifications/5.1/
COPY --chown=gradle:gradle \
    build.gradle \
    gradle.properties \
    settings.gradle \
    ./
COPY --chown=gradle:gradle src/ src/
RUN gradle \
    --no-build-cache \
    --no-daemon \
    --warn \
    assemble

FROM openjdk:11-jre-slim AS java-run
EXPOSE 8080
WORKDIR /app
COPY --from=java-build \
    /home/gradle/build/libs/docker-java11-0.0.1-SNAPSHOT.jar \
    ./
CMD java -jar docker-java11-0.0.1-SNAPSHOT.jar
