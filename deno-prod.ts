import {
  PrismaClient,
} from "https://cdn.jsdelivr.net/gh/zsnmwy/prisma-data-proxy-windmill-template@deno-client/0.0.13/deno/edge.ts"; // Change to your deno client

export async function main() {
  console.log(`DATABASE_URL=${Deno.env.get("DATABASE_URL")}`);

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

await main()