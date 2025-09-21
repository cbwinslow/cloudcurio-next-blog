import "@testing-library/jest-dom";
import "@testing-library/jest-dom/jest-globals";

// Mock Next.js router
jest.mock("next/router", () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    prefetch: jest.fn(),
    route: "/",
    pathname: "/",
    query: {},
    asPath: "/",
  }),
}));

// Mock Next.js navigation
jest.mock("next/navigation", () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    prefetch: jest.fn(),
  }),
  usePathname: () => "/",
  useSearchParams: () => new URLSearchParams(),
}));

// Mock NextAuth
jest.mock("next-auth/react", () => ({
  useSession: () => ({
    data: null,
    status: "unauthenticated",
  }),
  signIn: jest.fn(),
  signOut: jest.fn(),
}));

// Mock environment variables
process.env.NEXT_PUBLIC_APP_URL = "http://localhost:3000";
process.env.TEST_DATABASE_URL = "postgresql://test:test@localhost:5432/test";
process.env.NEXTAUTH_SECRET = "test-secret";
process.env.GITHUB_ID = "test-github-id";
process.env.GITHUB_SECRET = "test-github-secret";