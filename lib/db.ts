import { PrismaClient } from '@prisma/client'
import { PrismaD1 } from '@prisma/adapter-d1'

// For local development, we use a global singleton to avoid exhausting database connections.
declare global {
  // eslint-disable-next-line no-var
  var prisma: PrismaClient | undefined
}

const prismaSingleton = new PrismaClient()

const getPrismaInstance = (d1?: D1Database): PrismaClient => {
  if (process.env.NODE_ENV === 'production') {
    if (!d1) {
      throw new Error("D1 binding must be provided in production.");
    }
    const adapter = new PrismaD1(d1);
    return new PrismaClient({ adapter });
  }

  if (!global.prisma) {
    global.prisma = prismaSingleton;
  }
  return global.prisma;
};

export default getPrismaInstance;