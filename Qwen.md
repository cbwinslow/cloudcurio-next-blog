# Qwen Code - CloudCurio Project

This document contains information about the CloudCurio project and how to work with it using Qwen Code.

## Project Overview

CloudCurio is a full-stack application that includes:
- Next.js web application with authentication, billing, and admin features
- Prisma database schema for users, subscriptions, scripts, and review jobs
- GPU review worker system for code analysis
- Containerized analysis environment
- GitHub/GitLab webhook integration
- Stripe billing integration

## Repository Structure

- `/app` - Next.js application pages and components
- `/prisma` - Database schema and migrations
- `/worker` - Python-based GPU review worker
- `/container` - Docker container for analysis
- `/docs` - Setup and compliance documentation
- `/scripts` - Installation and deployment scripts
- `/public` - Static assets and logos

## Development Commands

```bash
# Install dependencies
pnpm i

# Generate Prisma client
pnpm prisma generate

# Push database schema
pnpm db:push

# Run development server
pnpm dev

# Build for production
pnpm build
```

## Key Technologies

- Next.js 14
- Prisma ORM
- SQLite (development) / PostgreSQL (production)
- NextAuth for authentication
- Stripe for billing
- Python for worker processes
- Docker for containerization
- GitHub/GitLab webhooks