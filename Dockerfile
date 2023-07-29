FROM ghcr.io/zsnmwy/prisma-data-proxy-base:latest

# https://github.com/zsnmwy/prisma-data-proxy
# Configuration https://github.com/zsnmwy/prisma-data-proxy/blob/ba921e61c116ae382f446c78915fa38987416c10/main.go#L19-L60

ARG PRISMA_VERSION="6b0aef69b7cdfc787f822ecd7cdc76d5f1991584"
ENV OS="linux-musl"
ENV QUERY_ENGINE_URL="https://binaries.prisma.sh/all_commits/${PRISMA_VERSION}/${OS}/query-engine.gz"

# install prisma
WORKDIR /app/prisma
# download query engine
RUN wget -O query-engine.gz $QUERY_ENGINE_URL && \
    gunzip query-engine.gz && \
    chmod +x query-engine

ENV TZ Asia/Shanghai
RUN apk add alpine-conf tzdata tini --no-cache && \
    /sbin/setup-timezone -z Asia/Shanghai && \
    apk del alpine-conf

WORKDIR /app

COPY ./prisma ./prisma
COPY ./wait-for-it.sh .
RUN chmod a+x ./wait-for-it.sh

ENV QUERY_ENGINE_PATH="/app/query-engine"
ENV PRISMA_SCHEMA_FILE="/app/prisma/schema.prisma"

EXPOSE 4466
CMD ["/app/main"]
ENTRYPOINT [ "tini", "--" ]