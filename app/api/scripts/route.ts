import { NextResponse } from 'next/server';
import { prisma } from '@/lib/db';
import crypto from 'crypto';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
export const runtime = 'nodejs';
export async function GET(){
  const all = await prisma.script.findMany({ orderBy: { updatedAt:'desc' } });
  return NextResponse.json({ scripts: all });
}
export async function POST(req: Request){
  const session = await getServerSession(authOptions);
  if(!session || (session.user as any)?.role !== 'admin'){
    return NextResponse.json({ error:'Forbidden' }, { status: 403 });
  }
  const { slug, title, description, version='0.1.0', channel='stable', content } = await req.json();
  if(!slug || !content || !title) return NextResponse.json({ error:'Missing fields' }, { status: 400 });
  const sha256 = crypto.createHash('sha256').update(content).digest('hex');
  const rec = await prisma.script.upsert({
    where: { slug },
    create: { slug, title, description, version, channel, content, sha256, authorId: (session as any).userId },
    update: { title, description, version, channel, content, sha256, authorId: (session as any).userId }
  });
  return NextResponse.json({ script: rec });
}
