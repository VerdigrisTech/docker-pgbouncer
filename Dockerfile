FROM alpine:latest

MAINTAINER Verdigris Technologies <infrastructure@verdigris.co>

ENV PG_USER=postgres
ENV PG_LOG_DIR=/var/log/pgbouncer
ENV PG_CONFIG_DIR=/etc/pgbouncer

RUN apk --update add coreutils git build-base automake libtool m4 autoconf \
    libevent-dev openssl-dev c-ares-dev \
    && git clone https://github.com/pgbouncer/pgbouncer.git \
    && cd pgbouncer \
    && git submodule init \
    && git submodule update \
    && ./autogen.sh \
    && ./configure --prefix=/usr/local --with-libevent=/usr/lib \
    && make && make install \
    && apk del git build-base automake autoconf libtool m4 \
    && rm -f /var/cache/apk/* \
    && cd .. && rm -Rf pgbouncer

RUN mkdir -p $PG_CONFIG_DIR $PG_LOG_DIR
RUN chmod -R 755 $PG_LOG_DIR
RUN chown -R $PG_USER:$PG_USER $PG_LOG_DIR

ADD entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

EXPOSE 6432

ENTRYPOINT ["./entrypoint.sh"]
