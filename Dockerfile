FROM debian:buster as base
ARG UID=1000
ARG GID=1000
RUN mkdir -p /data \
  && chown $UID:$GID -R /data \
  && addgroup --gid $GID --system homecx \
  && adduser --home /data \
    --gecos "" \
    --system \
    --disabled-password \
    --no-create-home \
    --uid $UID \
    homecx
RUN apt-get update \
  && apt-get install -y \
    curl \
    git \
    ssh \
    supervisor \
  && curl -fsSL https://get.docker.com | sh - \
  && usermod -aG docker homecx \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

FROM base as build-laminar
ARG LAMINAR_RELEASE="1.0"
ARG LAMINAR_TARBALL="https://github.com/ohwgiles/laminar/archive/$LAMINAR_RELEASE.tar.gz"
RUN apt-get update \
  && apt-get install -y \
    capnproto \
    cmake \
    g++ \
    libboost-dev \
    libcapnp-dev \
    libsqlite-dev \
    libsqlite3-dev \
    make \
    rapidjson-dev \
    zlib1g-dev \
  && mkdir -p /build /output \
  && cd /build/ \
  && curl -fsSL -o $LAMINAR_RELEASE.tar.gz $LAMINAR_TARBALL \
  && tar xzf $LAMINAR_RELEASE.tar.gz \
  && cd /build/laminar-$LAMINAR_RELEASE \
  && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/output \
  && make -j4 \
  && make install \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /build

FROM golang:1 as build-webhook
ARG WEBHOOK_RELEASE="2.7.0"
ARG LAMINAR_TARBALL="https://github.com/adnanh/webhook/archive/$WEBHOOK_RELEASE.tar.gz"
RUN apt-get update \
  && mkdir -p /build /output/usr/local/bin \
  && cd /build \
  && curl -fsSL -o $WEBHOOK_RELEASE.tar.gz $LAMINAR_TARBALL \
  && tar xzf $WEBHOOK_RELEASE.tar.gz \
  && cd webhook-$WEBHOOK_RELEASE \
  && go build github.com/adnanh/webhook \
  && cp webhook /output/usr/local/bin/webhook

FROM base
ARG git_sha=""
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="tmorin" \
      org.label-schema.license="MIT" \
      org.label-schema.vcs-ref="$git_sha" \
      org.label-schema.vcs-url="https://github.com/tmorin/docker-image-duplicity"
ENV LAMINAR_HOME=/data
ENV LAMINAR_BIND_HTTP=*:9000
ENV LAMINAR_TITLE=homecx
RUN apt-get update \
  && apt-get install -y \
    libcapnp-0.7.0 \
    sqlite3 \
    zlib1g \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*
USER homecx
COPY --from=build-laminar /output /
COPY --from=build-webhook /output /
COPY --chown=1000:1000 rootfs/ /
WORKDIR /data
EXPOSE 9000
EXPOSE 9001
ENTRYPOINT [ "/entrypoint.sh" ]
