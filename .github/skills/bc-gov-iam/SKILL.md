---
name: bc-gov-iam
description: BC Government Identity and Access Management — DIAM/Keycloak OIDC PKCE integration, realm selection, React oidc-client-ts setup, token lifecycle, backchannel logout, Common SSO vs DIAM comparison, and user attribute mapping. Use when implementing authentication, configuring an OIDC client, troubleshooting token refresh, or choosing between identity providers.
tools: Read, Grep, Glob
user-invocable: false
metadata:
  author: Ryan Loiselle
  version: "1.0"
compatibility: DIAM Keycloak. Common SSO (loginproxy.gov.bc.ca). React oidc-client-ts v3+. .NET 10 ASP.NET Core.
---

# BC Gov IAM Agent

Implements authentication and authorisation for BC Government applications using DIAM (Digital
Identity and Access Management) or Common SSO Keycloak.

**Related skills:**
- Security controls → [`../security-architect/SKILL.md`](../security-architect/SKILL.md)
- Vault for storing OIDC client secrets → [`../vault-secrets/SKILL.md`](../vault-secrets/SKILL.md)

---

## Identity Provider Reference

| Provider | Base URL | Realm | Use When |
|----------|----------|-------|----------|
| Common SSO (IDIR + BCeID) | `https://loginproxy.gov.bc.ca` | `standard` | Internal staff / business users |
| DIAM | `https://diam-dev.gov.bc.ca` / `diam.gov.bc.ca` | Project-specific | Ministry-specific brokered identity |
| IDIR (direct) | `https://loginproxy.gov.bc.ca` | `idir` | IDIR only, no BCeID needed |
| BCeID (direct) | `https://loginproxy.gov.bc.ca` | `bceidbasic` / `bceidbusiness` | BCeID only |

DIAM brokers to Common SSO as a federation layer. Most new projects use **Common SSO `standard`**
unless there is a specific requirement for DIAM's additional brokering or custom attribute mapping.

### OIDC Discovery URL
```
https://loginproxy.gov.bc.ca/auth/realms/standard/.well-known/openid-configuration
```

---

## PKCE Flow Summary

```
Browser                   React App              Keycloak
   |                          |                      |
   |── click Login ──>        |                      |
   |                  generate code_verifier         |
   |                  hash → code_challenge           |
   |                          |── GET /auth?          |
   |                          |   client_id           |
   |                          |   code_challenge ──>  |
   |                          |              redirect_uri + auth_code
   |                          |<── auth_code ─────────|
   |                          |── POST /token          |
   |                          |   code + code_verifier|
   |                          |──────────────────────>|
   |                          |<── access_token        |
   |                          |    refresh_token ─────|
```

No `client_secret` required for public clients (SPA). The `code_verifier`/`code_challenge` pair
replaces the implicit flow's reliance on a trusted origin.

---

## React Setup (`oidc-client-ts`)

### Install
```bash
npm install oidc-client-ts react-oidc-context
```

### Auth config
```js
// src/auth/authConfig.js — OIDC UserManager config
// Author: Ryan Loiselle | Date: <date>

export const oidcConfig = {
  authority:                import.meta.env.VITE_OIDC_AUTHORITY,
  // e.g. https://loginproxy.gov.bc.ca/auth/realms/standard
  client_id:                import.meta.env.VITE_OIDC_CLIENT_ID,
  redirect_uri:             `${window.location.origin}/callback`,
  post_logout_redirect_uri: `${window.location.origin}/`,
  response_type:            'code',
  scope:                    'openid profile email',
  automaticSilentRenew:     true,
  silent_redirect_uri:      `${window.location.origin}/silent-callback.html`,
  monitorSession:           true,
  filterProtocolClaims:     true,
  loadUserInfo:             true,
};
```

### Provider wrapping
```jsx
// src/main.jsx
import { AuthProvider } from 'react-oidc-context';
import { oidcConfig } from './auth/authConfig';

root.render(
  <AuthProvider {...oidcConfig}>
    <App />
  </AuthProvider>
);
```

### Callback page
```jsx
// src/pages/Callback.jsx — redirect landing page
import { useAuth } from 'react-oidc-context';
import { useNavigate } from 'react-router-dom';
import { useEffect } from 'react';

export default function Callback() {
  const auth = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!auth.isLoading && !auth.error) navigate('/');
  }, [auth.isLoading, auth.error]);

  if (auth.error) return <div>Login error: {auth.error.message}</div>;
  return <div>Logging in…</div>;
}
```

### Silent renew page
Create `/public/silent-callback.html`:
```html
<!doctype html>
<html><body>
<script src="/oidc-client-ts/dist/browser/oidc-client-ts.min.js"></script>
<script>new oidc.UserManager().signinSilentCallback();</script>
</body></html>
```

### Using the token in API calls
```js
// src/api/apiClient.js — axios interceptor using shared UserManager instance
import { UserManager } from 'oidc-client-ts';
import { oidcConfig } from '../auth/authConfig';
import axios from 'axios';

// Share the same UserManager instance used by AuthProvider
export const userManager = new UserManager(oidcConfig);

const apiClient = axios.create({ baseURL: import.meta.env.VITE_API_BASE_URL });

apiClient.interceptors.request.use(async (config) => {
  const user = await userManager.getUser();
  if (user?.access_token) {
    config.headers.Authorization = `Bearer ${user.access_token}`;
  }
  return config;
});

export default apiClient;
```

> Alternatively, if you are inside a React component or hook, read the token directly from
> `auth.user?.access_token` (via `useAuth()` from `react-oidc-context`) rather than
> creating a second `UserManager` instance.

---

## .NET API — JWT Validation

### Package
```bash
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
```

### Program.cs
```csharp
// OIDC JWT bearer authentication — validates tokens from Keycloak
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = builder.Configuration["Oidc:Authority"];
        // e.g. https://loginproxy.gov.bc.ca/auth/realms/standard
        options.Audience  = builder.Configuration["Oidc:ClientId"];
        options.RequireHttpsMetadata = !builder.Environment.IsDevelopment();
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer           = true,
            ValidateAudience         = true,
            ValidateLifetime         = true,
            ClockSkew                = TimeSpan.FromSeconds(60),
        };
    });

builder.Services.AddAuthorization();
// ...
app.UseAuthentication();
app.UseAuthorization();
```

### Extracting claims
```csharp
// returns the sub claim (Keycloak user ID)
private static Guid? GetUserId(ClaimsPrincipal user)
    => Guid.TryParse(user.FindFirstValue(ClaimTypes.NameIdentifier), out var id)
        ? id : null;
```

---

## Keycloak Client Registration

### Public client (React SPA)
| Setting | Value |
|---------|-------|
| Access type | `public` |
| Standard flow | `ON` |
| Implicit flow | `OFF` |
| Valid redirect URIs | `https://<app>-<license>-dev.apps.emerald.devops.gov.bc.ca/callback` |
| Post logout redirect URIs | `https://<app>-<license>-dev.apps.emerald.devops.gov.bc.ca/` |
| Web origins | same as redirect (no `+` wildcard in prod) |
| PKCE method | `S256` |

### Confidential client (API-to-API)
| Setting | Value |
|---------|-------|
| Access type | `confidential` |
| Service accounts | `ON` |
| `client_secret` | Store in Vault at `secret/<license>/<env>/oidc-client-secret` |

---

## Backchannel Logout (.NET API)

```csharp
// POST /logout/backchannel — handles Keycloak backchannel logout token
[HttpPost("/logout/backchannel")]
[AllowAnonymous]
[Consumes("application/x-www-form-urlencoded")]
public async Task<IActionResult> BackchannelLogout([FromForm] string logout_token)
{
    // 1. Validate logout_token JWT: issuer, audience, iat, jti
    // 2. Extract 'sub' or 'sid' claim
    var sub = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "(unknown)";
    // 3. Invalidate any server-side session or cached token for that sub/sid
    // 4. Return 200 OK or 400 Bad Request
    _logger.LogInformation("Backchannel logout received for sub={Sub}", sub);
    return Ok();
}
```

---

## IAM_KNOWLEDGE

```yaml
confirmed_facts:
  - "Common SSO 'standard' realm brokers IDIR, BCeID Basic, and BCeID Business"
  - "PKCE with S256 is mandatory for public clients — implicit flow is disabled on Common SSO"
  - "automaticSilentRenew uses a hidden iframe; may fail in Safari with ITP — use refresh_token_grant as fallback"
  - "Keycloak sub claim = user's UUID in the realm — use as the canonical user identifier"
  - "DIAM adds a JAG-specific brokering layer on top of Common SSO for JAG ministry projects"
  - "Vault path for OIDC client secret: secret/<license>/<env>/oidc-client-secret"
common_pitfalls:
  - "do NOT store access_token in localStorage — use oidc-client-ts in-memory store"
  - "ClockSkew must be set to at least 30s to tolerate server timing differences with Keycloak"
  - "Post logout redirect URI must be registered in Keycloak or the logout will fail silently"
  - "Bearer token audience validation: Keycloak issues 'account' audience by default — configure 'Add Audience' mapper"
```
