import { NextResponse } from 'next/server';
import { prisma } from '@/lib/db';
export const runtime = 'nodejs';
async function emit(event: string, payload: any){
  try{
    const axiom = process.env.AXIOM_TOKEN;
    if(axiom){
      await fetch('https://api.axiom.co/v1/datasets/cloudcurio/ingest', { method:'POST', headers:{ 'Authorization':`Bearer ${axiom}`, 'Content-Type':'application/json' }, body: JSON.stringify([{ event, ...payload, ts: new Date().toISOString() }]) });
    }
    const phKey = process.env.POSTHOG_KEY; const phHost = process.env.POSTHOG_HOST || 'https://app.posthog.com';
    if(phKey){
      await fetch(`${phHost}/capture/`, { method:'POST', headers:{ 'Content-Type':'application/json' }, body: JSON.stringify({ api_key: phKey, event, properties: payload }) });
    }
  }catch{}
}
export async function POST(req: Request, { params }:{ params:{ id: string } }){
  const token = process.env.WORKER_TOKEN ?? '';
  if(!token || req.headers.get('x-worker-token') !== token) return NextResponse.json({ error:'Unauthorized' }, { status: 401 });
  const { status, content, error, gpu } = await req.json();
  if(content){
    await prisma.reviewArtifact.upsert({ where: { jobId: params.id }, create: { jobId: params.id, content }, update: { content } });
  }
  const job = await prisma.reviewJob.update({ where: { id: params.id }, data: { status: status ?? 'done', resultUrl: `/reviews/${params.id}`, meta: { ...(error ? { error } : {}), gpu } } });
  await emit('review.complete', { id: job.id, status: job.status, gpu, error: error ?? null });
  return NextResponse.json({ ok: true });
}
