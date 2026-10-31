# Octop on Railway: the official image (built by Tencent from upstream docker/Dockerfile, tag v1.0.3b1)
# plus a small start wrapper that waits for Postgres and guarantees a policy-valid generated admin password.
FROM ghcr.io/tencentcloud/octop:1.0.3b1@sha256:2ac082ea72efa8497d67dcf5c2421b90ddbc0e8735fc91e49fdc77f2dd89af47
COPY railway/railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod 755 /usr/local/bin/railway-start.sh
ENV HOME=/data OCTOP_BIND_HOST=0.0.0.0 OCTOP_PORT=8088 PORT=8088
EXPOSE 8088
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD []
