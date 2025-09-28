let prisma: any = null;

// Only initialize Prisma in the right environment
if (typeof window === 'undefined' && process.env.DATABASE_URL) {
  // Skip initialization during build in CI
  if (process.env.NODE_ENV === 'production' && !process.env.CLOUDFLARE_ACCOUNT_ID) {
    // This is during build time, skip initialization
    prisma = null;
  } else {
    try {
      const { PrismaClient } = require('@prisma/client');
      prisma = new PrismaClient();
    } catch (error) {
      console.warn('Prisma client could not be initialized:', error);
      prisma = null;
    }
  }
}

export { prisma };
