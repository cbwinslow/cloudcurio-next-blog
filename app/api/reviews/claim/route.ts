import { NextResponse } from 'next/server';
import { prisma } from '@/lib/db';
export const runtime = 'nodejs';
export async function POST(req: Request){
  const token = process.env.WORKER_TOKEN ?? '';
  if(!token || req.headers.get('x-worker-token') !== token) return NextResponse.json({ error:'Unauthorized' }, { status: 401 });
  const { gpu, classes } = await req.json().catch(()=>({ gpu: null, classes: [] }));
  const job = await prisma.$transaction(async(tx)=>{
    const j = await tx.reviewJob.findFirst({
      where: { status: 'queued', ...(Array.isArray(classes) && classes.length ? { OR: classes.map(c => ({ meta: { path: ['class'], equals: c } })) } : {}) },
      orderBy: { createdAt: 'asc' }
    });
    if(!j) return null;
    await tx.reviewJob.update({ where: { id: j.id }, data: { status: 'running', meta: { ...(j.meta as any ?? {}), runner: gpu ?? 'unknown', claimedAt: new Date().toISOString() } } });
    return j;
  });
  return NextResponse.json({ job: job ?? null });
}
