import { NextResponse } from 'next/server';
import getPrismaInstance from '@/lib/db';
import { getServerSession } from 'next-auth';
import { getAuthOptions } from '@/lib/auth';

interface Env {
  REVIEWS_QUEUE: Queue;
  DB: D1Database;
}

export const runtime = 'edge'; // Required for queue access

export async function POST(req: Request){
  const d1 = (process.env as unknown as Env).DB;
  const session = await getServerSession(getAuthOptions(d1));

  if(!session || (session.user as any)?.role !== 'admin') {
    return NextResponse.json({ error:'Forbidden' }, { status: 403 });
  }

  const { repoUrl, klass = 'quick' } = await req.json();
  const meta = { class: klass };
  const prisma = getPrismaInstance(d1);

  // 1. Create the job in the database
  const job = await prisma.reviewJob.create({
    data: {
      repoUrl,
      status: 'queued',
      meta: JSON.stringify(meta),
    },
  });

  // 2. Send a message to the queue to trigger the worker
  const queue = (process.env as unknown as Env).REVIEWS_QUEUE;
  await queue.send({ jobId: job.id });

  const parsedJob = {
    ...job,
    meta: job.meta ? JSON.parse(job.meta) : null,
  };

  return NextResponse.json({ job: parsedJob });
}

export async function GET() {
  const prisma = getPrismaInstance((process.env as unknown as Env).DB);
  const jobs = await prisma.reviewJob.findMany({
    orderBy: { createdAt: 'desc' },
    take: 50,
  });

  const parsedJobs = jobs.map(job => ({
    ...job,
    meta: job.meta ? JSON.parse(job.meta) : null,
  }));

  return NextResponse.json({ jobs: parsedJobs });
}