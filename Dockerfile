ARG JENA_VERSION=4.2.0

FROM openjdk:16-slim-bullseye as build

ARG JENA_VERSION

RUN apt-get update \
    && apt-get install -y \
    maven \
    git \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/QAnswer/PageRankRDF.git \
    && cd PageRankRDF \
    && git checkout 25ff906ea8bd6d732aba2716f1d4246f1dbfdd8b \
    && mvn clean package

ARG JENA_ARCHIVE_URL=https://archive.apache.org/dist/jena/binaries

ADD ${JENA_ARCHIVE_URL}/apache-jena-fuseki-${JENA_VERSION}.tar.gz /
ADD ${JENA_ARCHIVE_URL}/apache-jena-${JENA_VERSION}.tar.gz /

RUN echo "359f8f99c8fa5968c1bdddcc39214db86da822804e3dd5fa182b86daff2d121a85b2102cffec853d9a80ceca7dea8ef65ef875919d653984af9bd297bc740167 apache-jena-fuseki-${JENA_VERSION}.tar.gz" | sha512sum --check \
    && echo "783f049742fa8d19cc2c7b0184adc2f13e6fdec4a68815e883c50155aa7f045edc2a38a17249ec40a2c020ce64208a7a14a400a0f6bbc47dda316fcf52833bfe apache-jena-${JENA_VERSION}.tar.gz" | sha512sum --check \
    && tar -xf apache-jena-fuseki-${JENA_VERSION}.tar.gz \
    && tar -xf apache-jena-${JENA_VERSION}.tar.gz

ADD entrypoint.sh /apache-jena-fuseki-${JENA_VERSION}
ADD config.ttl /apache-jena-fuseki-${JENA_VERSION}/run/

FROM openjdk:11-jre-slim-bullseye

ARG JENA_VERSION

ARG FUSEKI_DIR=/fuseki
ARG JENA_DIR=/jena

COPY --from=build /apache-jena-fuseki-${JENA_VERSION} ${FUSEKI_DIR}
COPY --from=build /apache-jena-${JENA_VERSION} ${JENA_DIR}
COPY --from=build /PageRankRDF/target/pagerank-0.1.0.jar /pagerank.jar

ENV PATH="${FUSEKI_DIR}/bin:${JENA_DIR}/bin:${PATH}" \
    JAVA_OPTIONS=""

VOLUME [ "/data" ]

EXPOSE 3030

WORKDIR ${FUSEKI_DIR}

ENTRYPOINT [ "./entrypoint.sh" ]
