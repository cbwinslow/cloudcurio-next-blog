import type { NextAuthOptions } from "next-auth";
import GitHub from "next-auth/providers/github";
import { PrismaAdapter } from "@auth/prisma-adapter";
import getPrismaInstance from "@/lib/db";

export const getAuthOptions = (d1?: D1Database): NextAuthOptions => {
  const prisma = getPrismaInstance(d1);

  return {
    adapter: PrismaAdapter(prisma) as any,
    providers: [
      GitHub({
        clientId: process.env.GITHUB_ID!,
        clientSecret: process.env.GITHUB_SECRET!,
        allowDangerousEmailAccountLinking: false,
      }),
    ],
    session: { strategy: "database" },
    callbacks: {
      async session({ session, user }) {
        (session as any).userId = user.id;
        (session.user as any).role = (user as any).role;
        return session;
      },
    },
    pages: { signIn: "/signin" },
  };
};