module.exports = {
  preset: "ts-jest",
  testEnvironment: "jest-environment-jsdom",
  setupFilesAfterEnv: ["<rootDir>/jest.setup.ts"],
  moduleNameMapper: {
    "^@/(.*)$": "<rootDir>/$1",
    "^@/components/(.*)$": "<rootDir>/app/components/$1",
    "^@/lib/(.*)$": "<rootDir>/lib/$1",
    "^@/app/(.*)$": "<rootDir>/app/$1"
  },
  testPathIgnorePatterns: [
    "<rootDir>/node_modules/",
    "<rootDir>/.next/"
  ],
  transform: {
    "^.+\\.(ts|tsx)$": "ts-jest"
  },
  collectCoverageFrom: [
    "app/**/*.{ts,tsx}",
    "lib/**/*.{ts,tsx}",
    "!app/**/*.d.ts",
    "!app/**/page.tsx",
    "!app/**/layout.tsx"
  ],
  coverageDirectory: "coverage",
  coverageReporters: ["json", "lcov", "text", "clover"]
};