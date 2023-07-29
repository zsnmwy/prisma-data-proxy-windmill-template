docker compose -f "docker-compose-prod.yml" up -d --build

echo "==== Prisma Migrate DB ===="
docker compose -f docker-compose-prod.yml logs migrate-db

echo "==== Prisma Data Proxy ===="
docker compose -f docker-compose-prod.yml logs data-proxy

echo "==== Deno LOG ===="
docker compose -f docker-compose-prod.yml logs deno

echo "==== TCP DUMP ===="
docker compose -f docker-compose-prod.yml logs tcpdump