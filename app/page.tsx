'use client';
import Image from 'next/image';
import Link from 'next/link';
export default function Page(){
  return (
    <main className="p-8 max-w-4xl mx-auto">
      <div className="flex items-center gap-4 mb-4">
        <Image src="/logos/logo_1.png" alt="CloudCurio" width={56} height={56}/>
        <h1 className="text-4xl font-bold">CloudCurio.cc</h1>
      </div>
      <p className="text-gray-600 mb-6">Curate, Compute, Create — in the Cloud</p>
      <nav className="space-x-4">
        <Link href="/scripts" className="underline">Scripts</Link>
        <Link href="/dotfiles" className="underline">Dotfiles</Link>
        <Link href="/blog" className="underline">Blog</Link>
        <Link href="/admin" className="underline">Admin</Link>
        <Link href="/chat" className="underline">Chat</Link>
      </nav>
    </main>
  );
}
