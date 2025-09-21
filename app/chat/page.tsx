import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { checkQuota } from "@/lib/usage";
import Link from "next/link";
export default async function ChatPage(){
  const session = await getServerSession(authOptions);
  if(!session) return <div className="p-8">Please <Link className="underline" href="/signin">sign in</Link>.</div>;
  const quota = await checkQuota((session as any).userId);
  if(!quota.ok){
    return (
      <div className="p-8 max-w-xl">
        <h1 className="text-2xl font-bold mb-2">Limit reached</h1>
        <p className="mb-4">You used {quota.used}/{quota.limit} requests today on the <b>{quota.plan}</b> plan.</p>
        <form action="/api/billing/create-checkout" method="post">
          <button className="rounded bg-blue-600 text-white px-4 py-2">Upgrade to Pro</button>
        </form>
      </div>
    );
  }
  return (
    <main className="p-8 max-w-2xl mx-auto">
      <h1 className="text-2xl font-bold mb-4">CloudCurio Chat</h1>
      <form className="space-y-2" action="/api/chat" method="post">
        <textarea name="prompt" className="w-full border rounded p-2" rows={6} placeholder="Ask something…"></textarea>
        <button className="rounded bg-black text-white px-4 py-2">Send</button>
      </form>
    </main>
  );
}
