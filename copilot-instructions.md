# Copilot Instructions for CloudCurio

This document provides guidelines for AI coding assistants (like GitHub Copilot) working with the CloudCurio codebase.

## Project Overview

CloudCurio is a full-stack application that provides GPU-accelerated code review services. The platform includes:

- Next.js web application with authentication, billing, and admin features
- Prisma ORM for database management
- Python workers for GPU-accelerated code analysis
- Containerized execution environments
- GitHub/GitLab webhook integration
- Stripe billing integration

## Technology Stack

### Frontend/Backend (Next.js)
- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript
- **Styling**: CSS Modules or Tailwind CSS (check existing components)
- **Authentication**: NextAuth.js with GitHub OAuth
- **Database**: Prisma ORM with SQLite (dev) / PostgreSQL (prod)
- **Validation**: Zod for schema validation
- **State Management**: React Context API or useState/useReducer

### Workers (Python)
- **Language**: Python 3.9+
- **Key Libraries**: 
  - concurrent.futures for parallel processing
  - subprocess for command execution
  - urllib for HTTP requests
  - json for data serialization
- **Analysis Tools**: ruff, bandit, semgrep
- **Containerization**: Docker with NVIDIA CUDA support

### Infrastructure
- **Containerization**: Docker
- **CI/CD**: GitHub Actions
- **Deployment**: systemd services for workers
- **Networking**: ZeroTier for distributed workers

## Coding Standards

### TypeScript/JavaScript
1. Use TypeScript for all new code
2. Follow functional programming patterns where possible
3. Use React Hooks (useState, useEffect, useContext, etc.)
4. Implement error boundaries for robust error handling
5. Use Zod for data validation
6. Follow Next.js App Router conventions
7. Use async/await for asynchronous operations

### Python
1. Use type hints for all function signatures and variable declarations
2. Follow PEP 8 style guide
3. Use descriptive variable and function names
4. Handle exceptions appropriately
5. Use context managers for resource management
6. Write docstrings for modules, classes, and functions

### Database
1. Use Prisma Schema for database modeling
2. Implement proper indexing for frequently queried fields
3. Use transactions for multi-step operations
4. Follow least-privilege principle for database access

## Testing Guidelines

### Next.js Application
1. Use Jest for unit tests
2. Use React Testing Library for component tests
3. Use Supertest for API integration tests
4. Aim for >80% test coverage for critical paths
5. Mock external dependencies in unit tests

### Python Workers
1. Use unittest or pytest for unit tests
2. Use mocking for external API calls
3. Test error conditions and edge cases
4. Validate JSON serialization/deserialization

## Security Considerations

1. Never commit secrets or API keys
2. Validate all user inputs
3. Implement proper authentication and authorization checks
4. Use secure headers and Content Security Policy
5. Sanitize user-generated content
6. Implement rate limiting for API endpoints
7. Follow OAuth best practices

## Performance Considerations

1. Implement caching for expensive operations
2. Use database indexing for frequently queried fields
3. Optimize database queries with includes/selects
4. Use pagination for large data sets
5. Implement proper error handling to prevent resource leaks
6. Use connection pooling for database connections

## File Structure Conventions

### Next.js Application
```
/app
  /api          # API routes
  /components   # Shared components
  /admin        # Admin pages
  /chat         # Chat interface
  /reviews      # Review pages
  /signin       # Authentication pages
  page.tsx      # Main landing page
  layout.tsx    # Root layout
```

### Worker Scripts
```
/worker
  review_worker_v2.py   # Main worker implementation
  README.md             # Worker documentation
```

### Container
```
/container
  Dockerfile            # Container definition
  requirements.txt      # Python dependencies
  review_runner.py      # Container entry point
```

## Common Patterns

### API Routes (Next.js)
```typescript
// Use this pattern for authenticated API routes
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";

export async function GET(req: Request) {
  const session = await getServerSession(authOptions);
  
  if (!session?.user) {
    return new Response("Unauthorized", { status: 401 });
  }
  
  // Implementation here
}
```

### Prisma Usage
```typescript
// Use try/catch for database operations
try {
  const result = await prisma.model.findUnique({
    where: { id: userId }
  });
  return new Response(JSON.stringify(result));
} catch (error) {
  console.error("Database error:", error);
  return new Response("Internal Server Error", { status: 500 });
}
```

### Python Worker Functions
```python
# Use type hints and proper error handling
def process_review(repo_url: str, gpu_device: Device) -> str:
    """Process a code review for a repository.
    
    Args:
        repo_url: URL of the repository to review
        gpu_device: GPU device to use for processing
        
    Returns:
        HTML report of the review results
        
    Raises:
        RuntimeError: If git clone fails
    """
    try:
        # Implementation here
        pass
    except Exception as e:
        # Proper error handling
        raise RuntimeError(f"Review processing failed: {str(e)}")
```

## Environment Variables

Key environment variables used in the application:

- `DATABASE_URL`: Database connection string
- `NEXTAUTH_SECRET`: Secret for NextAuth.js
- `GITHUB_ID`, `GITHUB_SECRET`: GitHub OAuth credentials
- `STRIPE_SECRET_KEY`: Stripe API key
- `STRIPE_PRICE_PRO`: Stripe price ID for Pro plan
- `WORKER_TOKEN`: Authentication token for workers
- `API_BASE`: Base URL for API endpoints

## Common APIs

### Prisma Models
- User: Authentication and profile information
- Subscription: Stripe subscription data
- Script: User-created scripts for delivery
- ReviewJob: Code review job queue
- ReviewArtifact: Results of code reviews

### API Endpoints
- `/api/auth/*`: Authentication endpoints
- `/api/github/webhook`: GitHub webhook receiver
- `/api/gitlab/webhook`: GitLab webhook receiver
- `/api/stripe/webhook`: Stripe webhook receiver
- `/api/reviews/claim`: Worker job claiming
- `/api/reviews/{id}/complete`: Worker job completion

## Worker Communication

Workers communicate with the main application through HTTP APIs:

1. Workers claim jobs via POST to `/api/reviews/claim`
2. Workers report results via POST to `/api/reviews/{id}/complete`
3. All communication requires proper authentication with WORKER_TOKEN

## Troubleshooting Tips

1. Check environment variables are properly set
2. Verify database connectivity
3. Check worker logs through systemd: `journalctl -u cloudcurio-worker -f`
4. Validate container images are properly built and accessible
5. Test GPU availability with nvidia-smi
6. Check network connectivity for distributed workers