FROM maven:3.3-jdk-8 AS build
RUN mkdir ~/r-source
WORKDIR ~/r-source
RUN git clone https://github.com/sonatype-nexus-community/nexus-repository-r
WORKDIR ./nexus-repository-r
RUN mvn clean install

ARG install_path=/opt/sonatype/nexus/

FROM sonatype/nexus3 AS final
WORKDIR /opt/sonatype/nexus
USER root
RUN mkdir ./system/org/sonatype/nexus/plugins/nexus-unpack-plugin
WORKDIR /opt/sonatype/nexus/system/org/sonatype/nexus/plugins/nexus-unpack-plugin
USER nexus
COPY  nexus-unpack-plugin-3.0.0-b2015020701.jar ./
WORKDIR /opt/sonatype/nexus
ARG t3
COPY --from=build ~/r-source/nexus-repository-r/target ./system/org/sonatype/nexus/plugins/nexus-repository-r/1.0.2
COPY nexus-unpack-plugin-3.0.0-b2015020701.jar ./system/org/sonatype/nexus/plugins/nexus-unpack-plugin
COPY nexus-oss-feature-3.14.0-04-features.xml ./system/com/sonatype/nexus/assemblies/nexus-oss-feature/3.14.0-04
COPY keystore.jks /opt/sonatype/nexus/etc/ssl
COPY nexus.properties /nexus-data/etc
