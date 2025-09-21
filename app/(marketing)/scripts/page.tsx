import Link from 'next/link';
import { prisma } from '@/lib/db';
export const dynamic = 'force-dynamic';
export default async function ScriptsIndex(){
  const scripts = await prisma.script.findMany({ orderBy: { updatedAt: 'desc' } });
  return (
    <main className="max-w-4xl mx-auto p-6">
      <h1 className="text-3xl font-bold mb-4">Scripts & Installers</h1>
      <ul className="space-y-4">
        {scripts.map(s => (
          <li key={s.id} className="border rounded-2xl p-4">
            <div className="flex items-center justify-between gap-4">
              <div>
                <h2 className="font-semibold text-lg">{s.title} <span className="text-xs text-gray-500">v{s.version} • {s.channel}</span></h2>
                <p className="text-sm text-gray-600">/{s.slug} — {s.description}</p>
              </div>
              <Link className="underline" href={`/raw/scripts/${s.slug}`}>Raw</Link>
            </div>
            <pre className="mt-3 bg-gray-50 p-3 rounded-xl overflow-auto text-xs">{`curl -fsSL https://cloudcurio.cc/raw/scripts/${s.slug} | bash`}</pre>
          </li>
        ))}
      </ul>
    </main>
  );
}
