# Stage 2: Create custom JRE with jlink
FROM eclipse-temurin:11-jdk AS jre-build

WORKDIR /app
COPY target/helloworld-0.0.1-SNAPSHOT.jar .

RUN jdeps \
    --ignore-missing-deps \
    --print-module-deps \
    -q \
    --class-path './*' \
    --module-path $JAVA_HOME/jmods \
    helloworld-0.0.1-SNAPSHOT.jar > jre-deps.info

RUN jlink \
    --add-modules $(cat jre-deps.info),java.desktop \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /javaruntime

# Stage 3: Final image
FROM debian:stable-slim
WORKDIR /app
COPY --from=jre-build /javaruntime /opt/java/
COPY target/helloworld-0.0.1-SNAPSHOT.jar .
ENV JAVA_HOME=/opt/java
ENV PATH="${JAVA_HOME}/bin:${PATH}"
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "helloworld-0.0.1-SNAPSHOT.jar"]
