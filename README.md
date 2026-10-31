# Octop — self-hosted multi-user, multi-agent AI assistant (Tencent, MIT). Deploy on Railway with one click.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/JJa_-f)

[Octop](https://github.com/TencentCloud/Octop) is TencentCloud's self-hosted AI assistant platform: multiple users and roles, multiple agents with their own workspaces and memory, knowledge bases, skills/plugins, scheduled tasks and chat-app channels, all from one web dashboard. This template runs the official `ghcr.io/tencentcloud/octop:1.0.3b1` image (built by upstream from `docker/Dockerfile`, pinned by digest) wrapped as `ghcr.io/onepush-dev/octop:1.0.3b1`, backed by Railway Postgres 18 — upstream's multi-user production backend — instead of the single-file SQLite default.

## Services
| Service | Image | Port | Volume |
|---|---|---|---|
| Octop | `ghcr.io/onepush-dev/octop:1.0.3b1` | Railway `PORT` (public HTTPS), health `/api/health` | `/data/.octop` (config, JWT secret, agent workspaces, knowledge indexes, plugins, logs) |
| Postgres | `ghcr.io/railwayapp-templates/postgres-ssl:18` | 5432 (private) | `/var/lib/postgresql/data` (control plane + agent memory) |

## Sign in
Zero inputs at deploy time. The admin account is created on first boot:

- **Username:** `admin`
- **Password:** the `OCTOP_DEFAULT_PASSWORD` variable on the Octop service (generated per deploy, always letters + digits so it passes Octop's policy)

Change it after first login (avatar menu → Change password). `OCTOP_DEFAULT_PASSWORD` is only used on the very first boot; editing it later does not reset an existing account. The UI starts in Chinese for the seeded admin — switch the language from the avatar menu.

## LLM provider
No API key is needed to deploy. Add your provider (OpenAI-compatible, Anthropic, DashScope, Ollama, …) and models in the dashboard, then create an agent. Optionally set `OPENAI_API_KEY` / `DASHSCOPE_API_KEY` as service variables.

## What the wrapper adds
`railway/railway-start.sh` runs before upstream's `docker-entrypoint.sh`:
1. listens on Railway's injected `PORT` (falls back to 8088), so the domain and health check always match;
2. sets `OCTOP_DATABASE_DRIVER=postgresql` when `OCTOP_DATABASE_URL` is a Postgres DSN and waits up to 180 s for the database, so first-boot `octop init` never races Postgres;
3. guarantees the generated admin password satisfies the policy, so the setup wizard is never left open.

Image defaults (override with service variables if needed): `HOME=/data`, `OCTOP_HOME=/data/.octop`, `OCTOP_BIND_HOST=0.0.0.0`, `OCTOP_LOG_LEVEL=info`, `OCTOP_ADMIN_USERNAME=admin`, `OCTOP_ADMIN_DISPLAY_NAME=Admin`, `OCTOP_DEFAULT_TIMEZONE=UTC`, `OCTOP_MAX_UPLOAD_MB=100`, `OCTOP_ENABLE_API_DOCS=false`, `LANGFUSE_TRACING_ENABLED=false`. All `OCTOP_*` settings are documented in upstream [docs/configuration.md](https://github.com/TencentCloud/Octop/blob/main/docs/configuration.md).

## Notes
- pgvector is not required (Octop's vector search is optional and off by default).
- Upstream's optional desktop/mobile/browser-automation extras need a display or devices and are not part of this template.
- Back up both volumes before upgrading the image tag.

## License
Octop is MIT-licensed by TencentCloud. This repo only holds Railway packaging.
