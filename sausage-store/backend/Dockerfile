FROM maven:3.9.3-eclipse-temurin-20-alpine AS builder
ARG VERSION=${VERSION}
WORKDIR /usr/src/app
COPY ./src ./src
COPY *.xml ./
RUN wget -O  YandexInternalRootCA.crt https://storage.yandexcloud.net/cloud-certs/CA.pem \
    && mvn package -Dversion.application=${VERSION} -Dmaven.test.skip=true

# шаг релиза
FROM bellsoft/liberica-runtime-container:jre-17-slim-musl
ARG VERSION=${VERSION}
WORKDIR /app
COPY --from=builder /usr/src/app/YandexInternalRootCA.crt .
RUN keytool -importcert -file YandexInternalRootCA.crt \
    -alias yandex -cacerts -storepass changeit -noprompt \
    #&& rm -rf YandexInternalRootCA.crt \
    && addgroup --system jaruser \
    && adduser -S -s /bin/false -G jaruser jaruser -D -H
COPY --chown=jaruser:jaruser \
     --from=builder /usr/src/app/target/sausage-store-backend-${VERSION}.jar ./sausage-store.jar
EXPOSE 8080
USER jaruser
ENTRYPOINT ["java", "-jar", "-Dmyserver.bindPort=8080", "/app/sausage-store.jar"]
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "curl --fail -s http://localhost:8080/actuator/health" ]