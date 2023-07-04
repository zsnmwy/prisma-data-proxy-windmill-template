FROM ghcr.io/zsnmwy/prisma-data-proxy:latest

ARG PRISMA_VERSION="4bc8b6e1b66cb932731fb1bdbbc550d1e010de81"
ENV OS="linux-musl"
ENV QUERY_ENGINE_URL="https://binaries.prisma.sh/all_commits/${PRISMA_VERSION}/${OS}/query-engine.gz"
ENV MIGRATION_ENGINE_URL="https://binaries.prisma.sh/all_commits/${PRISMA_VERSION}/${OS}/migration-engine.gz"

# install prisma
WORKDIR /app/prisma
# download query engine
RUN wget -O query-engine.gz $QUERY_ENGINE_URL && \
    gunzip query-engine.gz && \
    chmod +x query-engine
# download migration engine
RUN wget -O migration-engine.gz $MIGRATION_ENGINE_URL && \
    gunzip migration-engine.gz && \
    chmod +x migration-engine

ENV TZ Asia/Shanghai
RUN apk add alpine-conf tzdata tini --no-cache && \
    /sbin/setup-timezone -z Asia/Shanghai && \
    apk del alpine-conf

WORKDIR /app

COPY ./prisma ./prisma
COPY ./wait-for-it.sh .
RUN chmod a+x ./wait-for-it.sh

ENV MIGRATION_LOCK_FILE="/app/prisma/migration.lock"
ENV QUERY_ENGINE_PATH="/app/query-engine"
ENV MIGRATION_ENGINE_PATH="/app/migration-engine"
ENV PRISMA_SCHEMA_FILE="/app/prisma/schema.prisma"

EXPOSE 4466
CMD ["/app/main"]
ENTRYPOINT [ "tini", "--" ]