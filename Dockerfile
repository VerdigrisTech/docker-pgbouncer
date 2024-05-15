FROM alpine:3.19.1 AS builder
ARG VERSION=1.21.0

RUN apk --update add \
    coreutils \
    curl \
    build-base \
    automake \
    libtool \
    m4 \
    autoconf \
    libevent-dev \
    openssl-dev \
    c-ares-dev

WORKDIR /tmp
RUN curl -sSL https://pgbouncer.github.io/downloads/files/${VERSION}/pgbouncer-${VERSION}.tar.gz | tar xvz

WORKDIR /tmp/pgbouncer-${VERSION}

RUN ./autogen.sh
RUN ./configure --prefix=/usr/local
RUN make
RUN make install

FROM alpine:3.19.1

LABEL maintainer="Verdigris Technologies <infrastructure@verdigris.co>"

ARG PGBOUNCER_USER=pgbouncer
ARG PGBOUNCER_GROUP=pgbouncer
ARG PGBOUNCER_UID=1001
ARG PGBOUNCER_GID=1001
ARG PGBOUNCER_LOG_DIR=/var/log/pgbouncer
ARG PGBOUNCER_CONFIG_DIR=/etc/pgbouncer

COPY --from=builder /usr/local/bin/pgbouncer /usr/local/bin/pgbouncer

RUN \
  # Ensure busybox is upgraded to latest version for security reasons
  apk add -U --no-cache --upgrade busybox \
  # PgBouncer library dependencies
  && apk add -U --no-cache c-ares dumb-init libevent postgresql15-client

RUN mkdir -p $PGBOUNCER_CONFIG_DIR $PGBOUNCER_LOG_DIR
RUN chmod -R 755 $PGBOUNCER_LOG_DIR

RUN addgroup -g ${PGBOUNCER_GID} ${PGBOUNCER_GROUP} \
  && adduser -D -u ${PGBOUNCER_UID} -G ${PGBOUNCER_GROUP} ${PGBOUNCER_USER}

RUN chown -R $PGBOUNCER_USER:$PGBOUNCER_GROUP $PGBOUNCER_CONFIG_DIR
RUN chown -R $PGBOUNCER_USER:$PGBOUNCER_GROUP $PGBOUNCER_LOG_DIR

USER ${PGBOUNCER_UID}:${PGBOUNCER_GID}

COPY default-pgbouncer.ini ${PGBOUNCER_CONFIG_DIR}/pgbouncer.ini

ENTRYPOINT ["/usr/bin/dumb-init", "--rewrite=15:2", "--"]
CMD ["pgbouncer", "${PGBOUNCER_CONFIG_DIR}/pgbouncer.ini"]
