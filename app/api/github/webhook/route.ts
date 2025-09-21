import { NextResponse } from 'next/server';
import crypto from 'crypto';
import { prisma } from '@/lib/db';
export const runtime = 'nodejs';
function verify(sig: string|null, body: string){
  const secret = process.env.GITHUB_WEBHOOK_SECRET ?? '';
  if(!secret || !sig) return false;
  const hmac = crypto.createHmac('sha256', secret).update(body).digest('hex');
  return `sha256=${hmac}` === sig;
}
export async function POST(req: Request){
  const raw = await req.text();
  if(!verify(req.headers.get('x-hub-signature-256'), raw)) return new NextResponse('Invalid signature', { status: 401 });
  const evt = JSON.parse(raw);
  const type = (req.headers.get('x-github-event')||'').toLowerCase();
  if(type === 'pull_request'){
    const action = evt.action;
    if(['opened','synchronize','reopened'].includes(action)){
      const repoUrl = evt.pull_request?.html_url || evt.repository?.html_url;
      const job = await prisma.reviewJob.create({ data: { repoUrl, status: 'queued', meta: { provider: 'github', pr: evt.pull_request?.number, class: 'quick' } } });
      return NextResponse.json({ ok:true, job });
    }
  }
  return NextResponse.json({ ok:true });
}
