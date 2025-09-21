import testPrisma from './testDb';

export async function createTestUser(role: string = 'member') {
  return await testPrisma.user.create({
    data: {
      name: 'Test User',
      email: `test-${Date.now()}@example.com`,
      role,
    },
  });
}

export async function createTestReviewJob(repoUrl: string = 'https://github.com/test/repo') {
  return await testPrisma.reviewJob.create({
    data: {
      repoUrl,
      status: 'queued',
    },
  });
}

export async function cleanupTestData() {
  // Clean up in reverse order of dependencies
  await testPrisma.reviewArtifact.deleteMany({});
  await testPrisma.reviewJob.deleteMany({});
  await testPrisma.session.deleteMany({});
  await testPrisma.account.deleteMany({});
  await testPrisma.user.deleteMany({});
}