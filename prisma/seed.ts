import { Prisma, PrismaClient } from "@prisma/client";

console.log(`process.env.DATABASE_URL = ${process.env.DATABASE_URL}
process.env.DIRECT_URL = ${process.env.DIRECT_URL}
    `);

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DIRECT_URL,
    },
  },
});

async function main() {
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
