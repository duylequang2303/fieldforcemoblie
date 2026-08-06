# OmniRoute Local Dashboard - Login Guide

## Server Info
- **URL**: http://localhost:20128
- **Process**: `omniroute` (Discover PID using `pgrep omniroute`, usually runs from npm global modules)
- **Config**: `.env` located at your npm global modules directory of `omniroute`

## Credentials
- **Email**: `admin@local`
- **Password**: Non-default password configured in `.env` (specified via `INITIAL_PASSWORD`)

## Login via CLI (curl)

```bash
# 1. Login and save cookies (Replace <YOUR_PASSWORD> with your actual INITIAL_PASSWORD config)
curl -s -c /tmp/omniroute_cookies.txt -X POST "http://localhost:20128/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@local", "password": "<YOUR_PASSWORD>"}'

# Alternatively, enter password interactively to avoid writing it in bash history:
read -sp "Enter password: " PASSWORD
echo
curl -s -c /tmp/omniroute_cookies.txt -X POST "http://localhost:20128/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"admin@local\", \"password\": \"$PASSWORD\"}"

# 2. Access dashboard pages
curl -s -b /tmp/omniroute_cookies.txt "http://localhost:20128/dashboard/free-tiers"

# 3. Access API directly
curl -s -b /tmp/omniroute_cookies.txt "http://localhost:20128/api/free-tier/summary"
```

## Key API Endpoints (authenticated)

| Endpoint | Description |
|----------|-------------|
| `/api/free-tier/summary` | Free tier model limits summary (523 models, 43 pools) |
| `/dashboard/free-tiers` | Dashboard UI page |
| `/api/auth/login` | POST login (returns `auth_token` cookie) |


## Quick Test
```bash
# One-liner to get free tier data
curl -s -b /tmp/omniroute_cookies.txt "http://localhost:20128/api/free-tier/summary" | jq '.steadyRecurringTokens, .modelCount, .poolCount'
```

## Notes
- Cookie `auth_token` expires in 30 days (`Max-Age=2592000`)
- Server runs on port 20128 with `NODE_ENV=production`
- `AUTH_COOKIE_SECURE=false` allows HTTP localhost
- `REQUIRE_API_KEY=false` so dashboard auth is the only gate