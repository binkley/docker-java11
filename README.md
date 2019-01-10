# Docker and Java 11

* [Gradle 5.1](https://docs.gradle.org/5.1/release-notes.html)
* [Java 11](https://openjdk.java.net/projects/jdk/11/)
* [Spring Boot 2.1](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-2.1-Release-Notes)
* [Docker](https://blog.docker.com/2018/11/introducing-docker-engine-18-09/)

## Build and run

```bash
$ ./run-it.sh
```

After the service is read, in another terminal:

```bash
$ http localhost:8080/actuator health
```

Note: the container image name is "tmp".
