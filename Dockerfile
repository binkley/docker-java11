# Avoid the "Welcome to Gradle" message every build
FROM gradle:5.1-jdk11 AS java-pre-build
USER gradle:gradle
RUN touch /tmp/release-features.rendered

FROM gradle:5.1-jdk11 AS java-build
USER gradle:gradle
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

FROM openjdk:11.0.1-jre-slim AS java-run
RUN apt-get update && apt-get install --yes
EXPOSE 8080
RUN groupadd app
RUN useradd \
    --gid app \
    --shell /dev/null \
    app
USER app:app
WORKDIR /home/app
COPY --from=java-build \
    /home/gradle/build/libs/docker-java11-0.0.1-SNAPSHOT.jar \
    ./
CMD java -jar docker-java11-0.0.1-SNAPSHOT.jar
