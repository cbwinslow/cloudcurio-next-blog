import { NextResponse } from "next/server";
import { stripe } from "@/lib/stripe";
import { prisma } from "@/lib/db";
export const runtime = "nodejs";
export async function POST(req: Request){
  const sig = req.headers.get("stripe-signature");
  const raw = await req.text();
  let event;
  try {
    event = stripe.webhooks.constructEvent(raw, sig!, process.env.STRIPE_WEBHOOK_SECRET!);
  } catch (err:any) {
    return new NextResponse(`Webhook Error: ${err.message}`, { status: 400 });
  }
  switch(event.type){
    case "customer.subscription.created":
    case "customer.subscription.updated":{
      const s = event.data.object as any;
      const stripeSubId = s.id as string;
      const priceId = s.items.data[0].price.id as string;
      const status = s.status as string;
      const customer = await stripe.customers.retrieve(s.customer);
      const email = (customer as any).email as string;
      const user = await prisma.user.findUnique({ where: { email } });
      if(user){
        await prisma.subscription.upsert({
          where: { stripeSubId },
          create: {
            userId: user.id, stripeSubId, stripePriceId: priceId, status,
            plan: priceId === process.env.STRIPE_PRICE_PRO ? 'pro' : 'enterprise',
            currentPeriodEnd: new Date(s.current_period_end * 1000)
          },
          update: {
            status, stripePriceId: priceId, currentPeriodEnd: new Date(s.current_period_end * 1000),
          }
        });
      }
      break;
    }
    case "customer.subscription.deleted":{
      const s = event.data.object as any;
      await prisma.subscription.delete({ where: { stripeSubId: s.id } }).catch(()=>{});
      break;
    }
  }
  return NextResponse.json({ received: true });
}
