import { prisma } from '@/lib/db';
import { notFound } from 'next/navigation';

export function generateStaticParams() {
  // Return empty array for build-time - dynamic routes will be handled at runtime
  return [];
}

export default async function ReviewPage({ params }:{ params:{ id:string } }){
  // Handle build time when database is not available
  if (!prisma) {
    return (
      <main className="max-w-5xl mx-auto p-6">
        <h1 className="text-2xl font-bold mb-4">Review Report</h1>
        <p className="text-gray-600">Review will be available after deployment.</p>
      </main>
    );
  }

  const art = await prisma.reviewArtifact.findUnique({ where: { jobId: params.id }, include: { job: true } });
  if(!art) return notFound();
  return (
    <main className="max-w-5xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-4">Review Report</h1>
      <article className="prose" dangerouslySetInnerHTML={{ __html: art.content }} />
    </main>
  );
}
