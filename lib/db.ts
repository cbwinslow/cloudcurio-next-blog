let prisma: any = null;

// Only initialize Prisma in runtime with proper environment
if (typeof window === 'undefined' && process.env.DATABASE_URL && process.env.NODE_ENV !== 'production') {
  try {
    const { PrismaClient } = require('@prisma/client');
    prisma = new PrismaClient();
  } catch (error) {
    console.warn('Prisma client could not be initialized:', error);
    prisma = null;
  }
}

export { prisma };
