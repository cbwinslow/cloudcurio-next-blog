import { NextResponse } from 'next/server';
import { prisma } from '@/lib/db';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
export const runtime = 'nodejs';
export async function POST(req: Request){
  const session = await getServerSession(authOptions);
  if(!session || (session.user as any)?.role !== 'admin') return NextResponse.json({ error:'Forbidden' }, { status: 403 });
  const { repoUrl, klass='quick' } = await req.json();
  const job = await prisma.reviewJob.create({ data: { repoUrl, meta: { class: klass } } });
  return NextResponse.json({ job });
}
export async function GET(){
  const jobs = await prisma.reviewJob.findMany({ orderBy: { createdAt: 'desc' }, take: 50 });
  return NextResponse.json({ jobs });
}
