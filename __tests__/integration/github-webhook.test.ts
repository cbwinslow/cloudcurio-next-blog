/**
 * @jest-environment node
 */
import { cleanupTestData } from '../testHelpers';
import testPrisma from '../testDb';
import crypto from 'crypto';

// Mock the actual prisma client to use our test database
jest.mock('@/lib/db', () => ({
  prisma: testPrisma,
}));

// The secret used in the test
const GITHUB_WEBHOOK_SECRET = 'test-secret';

describe('GitHub Webhook API', () => {
  beforeEach(async () => {
    await cleanupTestData();
    process.env.GITHUB_WEBHOOK_SECRET = GITHUB_WEBHOOK_SECRET;
  });

  afterEach(() => {
    delete process.env.GITHUB_WEBHOOK_SECRET;
  });

  it('should reject requests with an invalid signature', async () => {
    const { POST } = await import('@/app/api/github/webhook/route');

    const request = new Request('http://localhost/api/github/webhook', {
      method: 'POST',
      headers: {
        'x-github-event': 'pull_request',
        'x-hub-signature-256': 'sha256=invalid-signature',
      },
      body: JSON.stringify({ action: 'opened' }),
    });

    const response = await POST(request);
    expect(response.status).toBe(401);
    const text = await response.text();
    expect(text).toBe('Invalid signature');
  });

  it('should handle non-pull-request events gracefully', async () => {
    const { POST } = await import('@/app/api/github/webhook/route');
    const payload = JSON.stringify({ some: 'data' });
    const signature = `sha256=${crypto.createHmac('sha256', GITHUB_WEBHOOK_SECRET).update(payload).digest('hex')}`;

    const request = new Request('http://localhost/api/github/webhook', {
      method: 'POST',
      headers: {
        'x-github-event': 'ping',
        'x-hub-signature-256': signature,
      },
      body: payload,
    });

    const response = await POST(request);
    expect(response.status).toBe(200);
    const data = await response.json();
    expect(data.ok).toBe(true);
  });

  it('should create a review job for a new pull request', async () => {
    const { POST } = await import('@/app/api/github/webhook/route');
    const payload = {
      action: 'opened',
      pull_request: {
        number: 123,
        html_url: 'https://github.com/test/repo/pull/123',
      },
      repository: {
        html_url: 'https://github.com/test/repo',
      }
    };
    const body = JSON.stringify(payload);
    const signature = `sha256=${crypto.createHmac('sha256', GITHUB_WEBHOOK_SECRET).update(body).digest('hex')}`;

    const request = new Request('http://localhost/api/github/webhook', {
      method: 'POST',
      headers: {
        'x-github-event': 'pull_request',
        'x-hub-signature-256': signature,
      },
      body: body,
    });

    const response = await POST(request);
    expect(response.status).toBe(200);
    const data = await response.json();
    expect(data.ok).toBe(true);
    expect(data.job).toBeDefined();
    expect(data.job.repoUrl).toBe('https://github.com/test/repo/pull/123');

    const jobInDb = await testPrisma.reviewJob.findUnique({ where: { id: data.job.id } });
    expect(jobInDb).not.toBeNull();
    expect(jobInDb?.repoUrl).toBe('https://github.com/test/repo/pull/123');
    const meta = JSON.parse(jobInDb!.meta!);
    expect(meta.provider).toBe('github');
    expect(meta.pr).toBe(123);
  });
});