# prisma-data-proxy-windmill-template


## TLDR

1. Fork this repo
2. Change Prisma Schema and push them to github
3. The Github Action will auto build
    - the deno client - Branch deno-client
    - `ghcr.io/${{ github.actor }}/prisma-data-proxy-windmill-template:${{ env.package_version }}` - Docker image / GHCR Registry
    - `ghcr.io/${{ github.actor }}/prisma-migrate-db-windmill-template:${{ env.package_version }}` - Docker image / GHCR Registry
4. Deploy The Prisma Data Proxy
   - docker compose
   - k8s
5. Connect to Prisma Data Proxy with Deno

```ts
import {
  Prisma,
  PrismaClient,
} from "https://cdn.jsdelivr.net/gh/zsnmwy/prisma-data-proxy-windmill-template@deno-client/0.0.3/deno/edge.ts"; // Change to your deno client

type PrismaDataProxy = {
  url: string;
};

export async function main(
  prismaDataProxy: PrismaDataProxy,
) {
  const prisma = new PrismaClient({
    datasources: { db: { url: prismaDataProxy.url } }
  })
  const createUser = await prisma.user.create({
    data: {
      email: "123@gmail.com",
      name: "123",
    }
  });
  console.log(createUser)

  const fetchUser = await prisma.user.findMany();
  console.log(fetchUser);
}
```

OR

```ts
import {
  PrismaClient,
} from "https://cdn.jsdelivr.net/gh/zsnmwy/prisma-data-proxy-windmill-template@deno-client/0.0.3/deno/edge.ts"; // Change to your deno client

export async function main() {
  console.log(Deno.env.get("DATABASE_URL"));

  const prisma = new PrismaClient();
  const createUser = await prisma.user.create({
    data: {
      email: "123@gmail.com",
      name: "123",
    }
  });
  console.log(createUser)

  const fetchUser = await prisma.user.findMany();
  console.log(fetchUser);
}
```

## Detail Flow

Prisma Edge Client -- Send GraphQL --> Prisma Data Proxy( Wrapper ) --- Forward
The GraphQL Request To Prisma Query Engine ---> Prisma Query Engine --> DB

### Prisma Edge Client

Write the Prisma Schema.

Build the Deno Client base on the schema. `yarn prisma generate --data-proxy`

Send GraphQL To Prisma Data Proxy

### Prisma Data Proxy

Prisma Data Proxy starts a Prisma Query Engine base on config.

Make it listen on the specific port.

```ts
/app/query-engine --datamodel-path ./prisma/schema.prisma --host 0.0.0.0 --enable-playground --port 4467 --enable-raw-queries --enable-metrics --dataproxy-metric-override --enable-telemetry-in-response
```

Prisma Query Engine will parse the Prisma schema and builds the GraphQL schema.
Prisma Data Proxy will accept requests from the Prisma Edge Client. 
It will check the requested permission. Then forward the request to Prisma Query Engine.

### Prisma Query Engine

Accept the request - GraphQL from Prisma Data Proxy. Query DB and return data.

Prisma Client Edge does not support some Prisma features. Like metrics.
That means we need to remove the unsupported features.

Deno Client needs to rebuild on each DB version. And push them to S3.

The Prisma Migration Engine binary is not good for users.
So I build another Nodejs image to migrate and track the database.

### K8S Deployment

Init Container - init-db-migrate-deploy Main Container - prisma-data-proxy

Prisma Query Engine export metrics about performance.
