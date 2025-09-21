import { PrismaClient } from '@prisma/client';

// Create a separate Prisma client for testing
const testPrisma = new PrismaClient();

export default testPrisma;