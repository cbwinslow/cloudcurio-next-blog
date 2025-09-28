import { PrismaClient } from '@prisma/client';

// Conditional Prisma client initialization for build time
export const prisma = process.env.NODE_ENV === 'production' && !process.env.DATABASE_URL 
  ? null 
  : new PrismaClient();
