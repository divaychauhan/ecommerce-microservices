# ShopSphere — E-commerce Microservices

A team-ready starter project: seven FastAPI microservices, a responsive storefront, Docker Compose, Nginx routing, GitHub Actions CI, and Trivy image scanning.

## Architecture

- Frontend: static HTML, CSS and JavaScript served by Nginx.
- API gateway: Nginx routes `/api/users`, `/api/products`, `/api/cart`, `/api/orders`, `/api/payments`, `/api/inventory`, and `/api/notifications` to their services.
- Services: independent FastAPI containers.
- Local data: each service currently uses in-memory demo data. Replace this with PostgreSQL/Redis and persistent migrations before production.

## Run locally

Requirements: Docker Engine and Docker Compose plugin.

```bash
git clone <your-private-repo-url>
cd ecommerce-microservices
docker compose up --build
```

Open http://localhost:8080. API docs are available at `http://localhost:8080/api/<service>/docs`.

To stop: `docker compose down`. To remove containers: `docker compose down --remove-orphans`.

## Service endpoints

| Service | Health endpoint | Main endpoint |
|---|---|---|
| user-service | `/api/users/health` | `/api/users/` |
| product-service | `/api/products/health` | `/api/products/` |
| cart-service | `/api/cart/health` | `/api/cart/` |
| order-service | `/api/orders/health` | `/api/orders/` |
| payment-service | `/api/payments/health` | `/api/payments/` |
| inventory-service | `/api/inventory/health` | `/api/inventory/` |
| notification-service | `/api/notifications/health` | `/api/notifications/` |

## Team workflow

1. Create a **private** GitHub repository.
2. Push this project to the repository.
3. In GitHub: Settings → Collaborators and teams → Add people / teams. Give each person the minimum required role.
4. Protect `main`: require pull requests, passing status checks, and at least one review. Do not allow direct pushes for normal contributors.
5. Each teammate creates a branch, for example `feature/cart-api` or `security/trivy-gate`, and opens a pull request.
6. Keep secrets in GitHub Actions Secrets / Environments. Never commit `.env`, cloud keys, passwords, tokens, or real payment credentials.

## CI and image security

Each service has its own workflow under `.github/workflows/`. A workflow builds that service's Docker image, runs Trivy vulnerability scanning, and uploads a SARIF report to GitHub Code Scanning. HIGH and CRITICAL vulnerabilities fail the build by default. The workflow uses GitHub's `security-events: write` permission for SARIF upload.

The security owner should review Trivy findings, distinguish fixable issues from accepted risks, update base images/dependencies, and document any temporary exception. Do not suppress findings just to make a pipeline green.

## Suggested ownership

- Platform/DevOps owner: Compose, Nginx, CI/CD, branch protection, release process.
- Security owner: Trivy policies, vulnerability triage, SARIF findings, remediation PRs.
- Backend owners: service API, tests, persistence, API contracts.
- Frontend owner: storefront, accessibility, API integration.

## Important production gaps

This is a runnable learning/team starter, not a production payment platform. Before production: use managed databases and migrations, authentication/authorization, secrets manager, TLS, rate limiting, request validation, structured logs, distributed tracing, message broker/outbox for async events, idempotent payment handling, backups, and deployment health/rollback strategy. Payment service is a mock only and does not process real payments.
