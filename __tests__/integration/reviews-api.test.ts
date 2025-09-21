import { createTestUser, createTestReviewJob, cleanupTestData } from '../testHelpers';
import testPrisma from '../testDb';

// Mock NextAuth session
jest.mock('next-auth', () => ({
  getServerSession: jest.fn(),
}));

// Mock the actual prisma client to use our test database
jest.mock('@/lib/db', () => ({
  prisma: testPrisma,
}));

describe('Reviews API', () => {
  beforeEach(async () => {
    await cleanupTestData();
  });

  describe('GET /api/reviews', () => {
    it('should return a list of review jobs', async () => {
      // Create some test data
      await createTestReviewJob('https://github.com/test/repo1');
      await createTestReviewJob('https://github.com/test/repo2');

      // Import the route handler dynamically
      const { GET } = await import('@/app/api/reviews/route');
      
      // Call the GET handler
      const response = await GET();
      const data = await response.json();

      expect(response.status).toBe(200);
      expect(data.jobs).toHaveLength(2);
      expect(data.jobs[0].repoUrl).toBe('https://github.com/test/repo2'); // Most recent first
    });
  });

  describe('POST /api/reviews', () => {
    it('should reject unauthenticated requests', async () => {
      const { getServerSession } = await import('next-auth');
      (getServerSession as jest.Mock).mockResolvedValue(null);

      const { POST } = await import('@/app/api/reviews/route');
      
      const request = new Request('http://localhost:3000/api/reviews', {
        method: 'POST',
        body: JSON.stringify({ repoUrl: 'https://github.com/test/repo' }),
      });
      
      const response = await POST(request);
      const data = await response.json();

      expect(response.status).toBe(403);
      expect(data.error).toBe('Forbidden');
    });

    it('should create a review job for authenticated admin users', async () => {
      // Create a test admin user
      const adminUser = await createTestUser('admin');
      
      // Mock authenticated session
      const { getServerSession } = await import('next-auth');
      (getServerSession as jest.Mock).mockResolvedValue({
        user: { id: adminUser.id, role: 'admin' },
      });

      const { POST } = await import('@/app/api/reviews/route');
      
      const request = new Request('http://localhost:3000/api/reviews', {
        method: 'POST',
        body: JSON.stringify({ repoUrl: 'https://github.com/test/repo', klass: 'quick' }),
      });
      
      const response = await POST(request);
      const data = await response.json();

      expect(response.status).toBe(200);
      expect(data.job).toBeDefined();
      expect(data.job.repoUrl).toBe('https://github.com/test/repo');
      expect(data.job.meta.class).toBe('quick');
    });
  });
});