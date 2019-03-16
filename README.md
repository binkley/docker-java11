# Docker and Java 11

* [Gradle 5.2](https://docs.gradle.org/5.2/release-notes.html)
* [Java 11](https://openjdk.java.net/projects/jdk/11/)
* [Spring Boot 2.1](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-2.1-Release-Notes)
* [Docker](https://blog.docker.com/2018/11/introducing-docker-engine-18-09/)
* [Batect](https://batect.charleskorn.com) (in progress)

## Build and run

```bash
# Use `Dockerfile`, manually spin up container
$ ./run-it.sh

```

Or:
```
$ ./gradlew dockerRun
```

Or:

```bash
$ ./batect run -- -Dspring.profiles.active=demo
```

After the service is running, in another terminal:

```bash
# Outputs elided
$ http localhost:8080/actuator/health
$ http localhost:8080/actuator/info
$ http localhost:8080/actuator/env/activeProfiles
```

Note: the container image name is "tmp" when using Docker directly.

## TODO:

* `./gradlew dockerRun` fails (at least on Windows)
* Merge into [binkley/docker](https://github.com/binkley/docker)
