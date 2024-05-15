# docker-pgbouncer

[![Known Vulnerabilities](https://snyk.io/test/github/verdigristech/docker-pgbouncer/badge.svg)][snyk]

PgBouncer container based on Alpine Linux

## Building the image

### Specifying the PgBouncer version

To build the image with a new PgBouncer version, you can use the `--build-arg`
option to specify the version you want to use. For example, to build the image
with PgBouncer 1.21.0, you can run the following command:

```bash
docker build --build-arg VERSION=1.22.0 -t verdigristech/pgbouncer:1.22.0-alpine .
```

---

© 2017 - 2024 Verdigris Technologies, Inc. All rights reserved.

[snyk]: https://snyk.io/test/github/verdigristech/docker-pgbouncer
