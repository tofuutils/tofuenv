ARG BASH_VERSION=5
FROM "docker.io/bash:${BASH_VERSION}"

# Runtime dependencies
RUN apk add --no-cache --purge \
    curl

VOLUME /var/tofuenv

ENV TOFUENV_ROOT=/usr/local/lib/tofuenv \
    TOFUENV_CONFIG_DIR=/var/tofuenv \
    TOFUENV_TOFU_VERSION=latest

ARG TOFUENV_VERSION=1.0.0
RUN wget -O /tmp/tofuenv.tar.gz "https://github.com/tofuutils/tofuenv/archive/refs/tags/v${TOFUENV_VERSION}.tar.gz" \
 && tar -C /tmp -xf /tmp/tofuenv.tar.gz \
 && mv "/tmp/tofuenv-${TOFUENV_VERSION}/bin"/* /usr/local/bin/ \
 && mkdir -p /usr/local/lib/tofuenv \
 && mv "/tmp/tofuenv-${TOFUENV_VERSION}/lib" /usr/local/lib/tofuenv/ \
 && mv "/tmp/tofuenv-${TOFUENV_VERSION}/libexec" /usr/local/lib/tofuenv/ \
 && mkdir -p /usr/local/share/licenses \
 && mv "/tmp/tofuenv-${TOFUENV_VERSION}/LICENSE" /usr/local/share/licenses/tofuenv \
 && rm -rf /tmp/tofuenv*

ENTRYPOINT ["/usr/local/bin/tofu"]
