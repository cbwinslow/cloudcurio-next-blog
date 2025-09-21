'use client';
import React from 'react';
async function api(path: string, init?: RequestInit){
  const res = await fetch(path, { ...init, headers: { 'Content-Type':'application/json' } });
  if(!res.ok) throw new Error(await res.text());
  return res.json();
}
export default function AdminScripts(){
  const [items, setItems] = React.useState<any[]>([]);
  const [form, setForm] = React.useState({ slug:'bootstrap', title:'Bootstrap', description:'Sets up a fresh machine', version:'0.1.0', channel:'stable', content:'#!/usr/bin/env bash\nset -eo pipefail\necho "CloudCurio bootstrap"' });
  async function load(){ const { scripts } = await api('/api/scripts'); setItems(scripts); }
  React.useEffect(()=>{ load().catch(()=>{}); },[]);
  return (
    <main className="max-w-5xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-4">Scripts</h1>
      <form className="grid gap-2 mb-6" onSubmit={async(e)=>{ e.preventDefault(); await api('/api/scripts',{ method:'POST', body: JSON.stringify(form) }); await load(); }}>
        <div className="grid sm:grid-cols-2 gap-2">
          <input className="border rounded p-2" placeholder="slug" value={form.slug} onChange={e=>setForm({...form, slug:e.target.value})}/>
          <input className="border rounded p-2" placeholder="title" value={form.title} onChange={e=>setForm({...form, title:e.target.value})}/>
        </div>
        <input className="border rounded p-2" placeholder="description" value={form.description} onChange={e=>setForm({...form, description:e.target.value})}/>
        <div className="grid sm:grid-cols-2 gap-2">
          <input className="border rounded p-2" placeholder="version" value={form.version} onChange={e=>setForm({...form, version:e.target.value})}/>
          <select className="border rounded p-2" value={form.channel} onChange={e=>setForm({...form, channel:e.target.value})}>
            <option>stable</option><option>beta</option><option>canary</option><option>dotfile</option>
          </select>
        </div>
        <textarea className="border rounded p-2 font-mono" rows={12} value={form.content} onChange={e=>setForm({...form, content:e.target.value})}></textarea>
        <button className="rounded bg-blue-600 text-white px-4 py-2">Save</button>
      </form>
      <ul className="space-y-2">
        {items.map(it => (
          <li key={it.id} className="flex items-center justify-between border rounded p-3">
            <div>
              <div className="font-semibold">{it.title} <span className="text-xs text-gray-500">/{it.slug}</span></div>
              <div className="text-xs text-gray-500">v{it.version} • {it.channel} • downloads: {it.downloads}</div>
            </div>
            <a className="underline" href={`/raw/scripts/${it.slug}`} target="_blank">Raw</a>
          </li>
        ))}
      </ul>
    </main>
  );
}
