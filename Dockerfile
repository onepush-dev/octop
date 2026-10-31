# Octop on Railway: the official image (built by Tencent from upstream docker/Dockerfile, tag v1.0.3b1)
# plus a small start wrapper: Postgres wait, postgresql driver when OCTOP_DATABASE_URL is set,
# and a policy-valid generated admin password.
FROM ghcr.io/tencentcloud/octop:1.0.3b1@sha256:2ac082ea72efa8497d67dcf5c2421b90ddbc0e8735fc91e49fdc77f2dd89af47
COPY railway/railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod 755 /usr/local/bin/railway-start.sh
# Defaults live in the image so the Railway template only carries references and generated secrets.
# Any of these can still be overridden with a Railway service variable.
# The listen port follows Railway's injected PORT (fallback 8088), so domain + healthcheck always match.
ENV HOME=/data \
    OCTOP_HOME=/data/.octop \
    OCTOP_BIND_HOST=0.0.0.0 \
    OCTOP_LOG_LEVEL=info \
    OCTOP_ADMIN_USERNAME=admin \
    OCTOP_ADMIN_DISPLAY_NAME=Admin \
    OCTOP_DEFAULT_TIMEZONE=UTC \
    OCTOP_MAX_UPLOAD_MB=100 \
    OCTOP_ENABLE_API_DOCS=false \
    LANGFUSE_TRACING_ENABLED=false
EXPOSE 8088
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD []
