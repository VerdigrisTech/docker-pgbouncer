FROM alpine:3 AS builder

ARG PANDOC_VERSION=2.10

RUN apk --update add \
    coreutils \
    curl \
    git \
    build-base \
    automake \
    libtool \
    m4 \
    autoconf \
    libevent-dev \
    openssl-dev \
    c-ares-dev

WORKDIR /tmp
RUN curl -sSL https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz | tar xvz
RUN cp -r pandoc-${PANDOC_VERSION}/* /usr/

RUN git clone --recurse-submodules https://github.com/pgbouncer/pgbouncer.git
WORKDIR /tmp/pgbouncer
RUN ./autogen.sh
RUN ./configure --prefix=/usr/local
RUN make
RUN make install

FROM alpine:3

LABEL maintainer="Verdigris Technologies <infrastructure@verdigris.co>"

ENV PG_USER=postgres
ENV PG_LOG_DIR=/var/log/pgbouncer
ENV PG_CONFIG_DIR=/etc/pgbouncer

COPY --from=builder /usr/local/bin/pgbouncer /usr/local/bin/pgbouncer

RUN apk --update add c-ares libevent

RUN mkdir -p $PG_CONFIG_DIR $PG_LOG_DIR
RUN chmod -R 755 $PG_LOG_DIR
RUN adduser -D ${PG_USER}
RUN chown -R $PG_USER:$PG_USER $PG_LOG_DIR

ADD entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

EXPOSE 6432

ENTRYPOINT ["./entrypoint.sh"]
