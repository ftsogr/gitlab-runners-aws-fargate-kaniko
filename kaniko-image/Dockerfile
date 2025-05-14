FROM gcr.io/kaniko-project/executor:debug AS kaniko
FROM eclipse-temurin:17.0.14_7-jdk-noble

# Set environment variables
ENV JAVA_HOME=/opt/java/openjdk \
    PATH=${JAVA_HOME}/bin:/usr/local/bin:/kaniko/:$PATH \
    DOCKER_CONFIG=/kaniko/.docker/ \
    SSL_CERT_DIR=/kaniko/ssl/certs \
    DOCKER_CREDENTIAL_GCR_CONFIG=/kaniko/.config/gcloud/docker_credential_gcr_config.json \
    KANIKO_DIR=/kaniko

# Install required packages and tools
RUN apt-get update && apt-get install -y \
    openssh-server curl unzip tar jq \
    && mkdir -p /var/run/sshd \
    && curl -Lo /usr/local/bin/tini https://github.com/krallin/tini/releases/download/v0.19.0/tini-amd64 \
    && chmod +x /usr/local/bin/tini \
    && curl -Lo /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64 \
    && chmod +x /usr/local/bin/gitlab-runner \
    && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
    && apt-get install -y git-lfs \
    && git lfs install --skip-repo \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -f awscliv2.zip \
    && curl -fsSL https://downloads.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz -o maven.tar.gz \
    && mkdir -p /opt/maven \
    && tar -xzf maven.tar.gz -C /opt/maven --strip-components=1 \
    && rm -f maven.tar.gz \
    && ln -s /opt/maven/bin/mvn /usr/local/bin/mvn \
    && rm -rf /var/lib/apt/lists/*

# Copy Kaniko tools
COPY --from=kaniko /kaniko /kaniko
RUN chmod -R 777 /kaniko/ \
    && mkdir -p /kaniko/.docker /kaniko/ssl \
    && docker-credential-gcr config --token-source=env

# Copy configuration files and entrypoint.
COPY scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/* \
    && ln -s /usr/local/bin/entrypoint.sh

# Expose SSH port.
EXPOSE 22

# Execute a startup script.
ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
