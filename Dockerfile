# Intermediate build image we can prune
FROM alpine:latest as build

# This label can be used to prune
LABEL stage=build 

RUN apk --no-cache add openjdk11-jdk openjdk11-jmods 

ENV JAVA_MINIMAL="/opt/java-minimal"

# Use jlink to create a smaller Java runtime
RUN /usr/lib/jvm/java-11-openjdk/bin/jlink \
    --verbose \
    --add-modules java.base,java.management \
    --compress 2 --strip-debug --no-header-files --no-man-pages \
    --output "$JAVA_MINIMAL"

# Slim image with stripped down JRE
FROM alpine:latest

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.authors="contact+docker@roblehesa.com" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="Alpine Cobalt Strike" \
    org.label-schema.description="Lightweight Cobalt Strike server built on Alpine" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-url="https://github.com/robleh/cobaltstrike-alpine" \
    org.label-schema.vcs-ref=$VCF_REF

WORKDIR /opt

# Bring the downsized Java runtime from our build stage
ENV JAVA_HOME=/opt/java-minimal
ENV PATH="$PATH:$JAVA_HOME/bin"
COPY --from=build "$JAVA_HOME" "$JAVA_HOME"

COPY .cobaltstrike.license /root

# Retrieve a token and download Cobalt Strike tarball
RUN wget -q --post-data dlkey=$(cat /root/.cobaltstrike.license) -O - https://www.cobaltstrike.com/download | grep -m 1 -o '[a-f0-9]\{32\}' >> .token \
    && wget -q -P /opt https://www.cobaltstrike.com/downloads/$(cat .token)/cobaltstrike-dist.tgz \
    && rm .token \
    && tar -xvf /opt/cobaltstrike-dist.tgz \
    && rm /opt/cobaltstrike-dist.tgz

WORKDIR /opt/cobaltstrike

# Forcing the TLS version is required to prevent handshake errrors during
# the update process. Switch the teamserver shebang to a shell alpine has.
RUN sed -i 's/-jar update.jar/-Djdk.tls.client.protocols=TLSv1.2 -jar update.jar /g' update \
    && sed -i 's/bash/sh/g' teamserver \
    && ./update \
    && rm /root/.cobaltstrike.license 

# Container doesn't have UID env var, this stops a stderr warning from showing
ENV UID=0

ENTRYPOINT ["./teamserver"]
