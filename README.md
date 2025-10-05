# CloudCurio – Deployed on Cloudflare

This repository contains the full CloudCurio application, now re-architected for a serverless deployment on the Cloudflare platform. The new architecture leverages Cloudflare Pages for the frontend, Cloudflare Workers for serverless functions, and Cloudflare D1 for the database.

## Key Components

- **Next.js App**: A modern web application providing the user interface, API routes, and authentication.
- **Prisma**: The ORM used to interact with the Cloudflare D1 database.
- **Cloudflare Worker**: A serverless function that processes code reviews asynchronously.
- **Cloudflare D1**: A serverless SQL database that stores all application data.
- **Cloudflare Queues**: A messaging service for communication between the main app and the review worker.

## Getting Started

### Prerequisites

- Node.js 18+ and pnpm (or npm)
- A Cloudflare account
- Wrangler CLI (for interacting with Cloudflare services)

### Local Development

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd <repository-name>
    ```

2.  **Install dependencies**:
    ```bash
    pnpm install
    ```

3.  **Configure environment variables**:
    Copy the `.env.example` file to `.env.local` and fill in the required values for your local setup.
    ```bash
    cp .env.example .env.local
    ```

4.  **Set up the local database**:
    ```bash
    pnpm prisma generate
    pnpm db:push
    ```

5.  **Run the development server**:
    ```bash
    pnpm dev
    ```
    The application will be available at `http://localhost:3000`.

## Deployment

This application is designed to be deployed on Cloudflare.

1.  **Deploy the D1 Database**:
    Use the Wrangler CLI to deploy the database schema.
    ```bash
    npx wrangler d1 migrations apply cloudcurio-db --local
    npx wrangler d1 migrations apply cloudcurio-db --remote
    ```

2.  **Deploy the Review Worker**:
    Navigate to the `worker` directory and deploy the consumer worker.
    ```bash
    cd worker
    npx wrangler deploy
    cd ..
    ```

3.  **Deploy the Next.js App**:
    Connect your GitHub repository to Cloudflare Pages and configure the build settings. The application will be deployed automatically on pushes to the `main` branch.

### Webhooks

-   **GitHub**: Go to your repository's settings, add a webhook with the URL `https://yourdomain/api/github/webhook`, and set the `GITHUB_WEBHOOK_SECRET`.
-   **GitLab**: Add a webhook with the URL `https://yourdomain/api/gitlab/webhook` and set the `GITLAB_WEBHOOK_TOKEN`.

### Authentication (GitHub)

-   Create a GitHub OAuth app with the callback URL `https://yourdomain/api/auth/callback/github`.
-   Set `GITHUB_ID`, `GITHUB_SECRET`, and `NEXTAUTH_SECRET` in your environment variables.

### Billing (Stripe)

-   Create a new product and price in your Stripe account.
-   Set `STRIPE_SECRET_KEY` and `STRIPE_PRICE_PRO` in your environment variables.
-   Add a webhook endpoint in Stripe with the URL `https://yourdomain/api/stripe/webhook` and set `STRIPE_WEBHOOK_SECRET`.

### Testing

-   Run unit tests: `npm run test`
-   Run linting: `npm run lint`
-   Run type checking: `npm run type-check`