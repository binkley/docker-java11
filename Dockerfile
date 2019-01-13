# Avoid the "Welcome to Gradle" message every build
FROM openjdk:11.0.1-jdk AS pre-gradle-setup
RUN apt-get update && apt-get install --yes
RUN touch /tmp/release-features.rendered

FROM pre-gradle-setup AS gradle-setup
RUN groupadd gradle
RUN useradd \
    --create-home \
    --gid gradle \
    --shell /dev/null \
    gradle
USER gradle:gradle
WORKDIR /home/gradle
COPY --from=pre-gradle-setup --chown=gradle:gradle \
    /tmp/release-features.rendered \
    .gradle/notifications/5.1.1/
COPY --chown=gradle:gradle \
    ./gradlew \
    ./
COPY --chown=gradle:gradle gradle/ gradle/
RUN ./gradlew wrapper \
    --gradle-version 5.1.1 \
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
RUN ./gradlew \
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
