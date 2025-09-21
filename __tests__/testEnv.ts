// Test environment setup
export const TEST_ENV = {
  // Test database URL - using in-memory SQLite for tests
  DATABASE_URL: 'file:./test.db?connection_limit=1',
  
  // Mock environment variables
  NEXTAUTH_SECRET: 'test-secret',
  GITHUB_ID: 'test-github-id',
  GITHUB_SECRET: 'test-github-secret',
};