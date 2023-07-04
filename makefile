.ONESHELL:

VERSION ?= $(shell jq -r .version package.json)
PRISMA_VERSION ?= $(shell node_modules/.bin/prisma version | grep prisma | head -n 1 | cut -d ':' -f2 | tr -d "[:space:]")

display-version:
	node_modules/.bin/prisma version

build-deno-client:
	echo ========Build DENO Client========
	mkdir -p prisma/deno
	cp -f prisma/schema.prisma prisma/deno/schema.prisma
	sed -i '' '/previewFeatures/d' prisma/deno/schema.prisma || sed -i '/previewFeatures/d' prisma/deno/schema.prisma
	sed '/"prisma-client-js"/r prisma/deno/inject.txt' prisma/deno/schema.prisma | tee prisma/deno/schema.prisma.tmp
	mv prisma/deno/schema.prisma.tmp prisma/deno/schema.prisma
	node_modules/.bin/prisma format --schema prisma/deno/schema.prisma
	node_modules/.bin/prisma format --schema prisma/schema.prisma
	deno run -A --unstable "npm:prisma@${PRISMA_VERSION}" generate --data-proxy --schema=prisma/deno/schema.prisma

build-node-client:
	echo "Build Node Client"
	node_modules/.bin/prisma generate

.PHONY: build-client
build-client: display-version build-deno-client build-node-client

db-pull:
	node_modules/.bin/prisma db pull

db-push:
	node_modules/.bin/prisma db push