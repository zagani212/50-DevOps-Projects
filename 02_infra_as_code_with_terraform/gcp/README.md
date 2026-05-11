# GCP: Service account and Workload Identity Federation (for GitHub Actions)

This guide walks through creating a **service account (SA)** and a **Workload Identity Federation (WIF)** pool so GitHub Actions can authenticate to Google Cloud **without** storing a long-lived JSON key in GitHub.

Replace placeholders:

| Placeholder | Meaning |
|-------------|--------|
| `YOUR_GITHUB_USERNAME` / `YOUR_GITHUB_ORG` | GitHub user or organization that owns the repo |
| `YOUR_GITHUB_REPO` | Repository name (without `.git`) |
| `PROJECT_ID` | Your GCP project ID |
| `PROJECT_NUMBER` | Your GCP project **number** (numeric, shown in Cloud Console project settings) |

---

## 1. Create a service account (example name: `github-sa`)

1. Open **Google Cloud Console** → **IAM & Admin** → **Service Accounts** → **Create service account**.
2. **Service account name:** e.g. `github-sa` (the full email will look like `github-sa@PROJECT_ID.iam.gserviceaccount.com`).
3. Grant this service account the roles your Terraform / CI needs (adjust if your lab uses fewer services):

   - **Cloud SQL Admin** (`roles/cloudsql.admin`)
   - **Compute Admin** (`roles/compute.admin`)
   - **Service Account Admin** (`roles/iam.serviceAccountAdmin`)
   - **Service Account User** (`roles/iam.serviceAccountUser`)

4. Click **Done** (you can skip optional user grants unless you need humans to act as this SA).

> **Note:** Broad roles are convenient for demos; in production, prefer least-privilege custom roles or narrower predefined roles.

---

## 2. Create a Workload Identity Pool (example: `github-pool`)

1. Go to **IAM & Admin** → **Workload Identity Federation**.
2. **Create pool**.
   - **Pool name:** e.g. `github-pool`  
   - **Pool ID:** remember this (e.g. `github-pool`); it appears in principal strings.

---

## 3. Add an OIDC provider (GitHub Actions)

1. In the pool → **Add provider** → **OpenID Connect (OIDC)**.
2. **Provider name:** e.g. `github`.
3. **Issuer (URL):**  
   `https://token.actions.githubusercontent.com`
4. Continue / save as prompted.

---

## 4. Attribute mapping

In the provider configuration, set:

| Google attribute | OIDC assertion |
|------------------|----------------|
| `google.subject` | `assertion.sub` |
| `attribute.aud` | `assertion.aud` |
| `attribute.actor` | `assertion.actor` |
| `attribute.repository` | `assertion.repository` |

> Common typo: use **`google.subject`**, not `google.subjet`.

---

## 5. Attribute condition (restrict to one repo)

Restrict which GitHub repositories can exchange tokens for this pool. Example (single repo):

```text
assertion.repository == 'YOUR_GITHUB_USERNAME/YOUR_GITHUB_REPO'
```

For an organization-owned repo:

```text
assertion.repository == 'YOUR_GITHUB_ORG/YOUR_GITHUB_REPO'
```

Save the provider.

---

## 6. Allow the pool to impersonate `github-sa` (principal + `roles/iam.workloadIdentityUser`)

1. Open **IAM & Admin** → **Service Accounts** → select **`github-sa`**.
2. Open the **Permissions** tab → **Grant access** (or **Manage access**).
3. **New principal:** use a **principal set** that matches repositories allowed by your attribute condition.

   Example shape (adjust `PROJECT_NUMBER`, pool ID, owner, and repo):

   ```text
   principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/YOUR_GITHUB_USERNAME/YOUR_GITHUB_REPO
   ```

4. **Role:** **Workload Identity User** (`roles/iam.workloadIdentityUser`) — lets identities in that principal set call `generateAccessToken` for this service account.

> If the Console UI asks for “principal” with a different format, the idea is the same: bind the **WIF principal** (or principal set) that corresponds to your GitHub repo to **`github-sa`** with **Workload Identity User**.

---

## 7. Grant `github-sa` the token creator role (for the GitHub → GCP exchange path)

Some setups also add a binding so the **WIF pool** or a specific **principal** can mint tokens. In your flow you described:

1. On **`github-sa`** → **Permissions** → **Grant access**.
2. **Principal:** a principal set such as:

   ```text
   principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/YOUR_GITHUB_ORG/YOUR_GITHUB_REPO
   ```

3. **Role:** **Service Account Token Creator** (`roles/iam.serviceAccountTokenCreator`).

Use the same pool ID (`github-pool`) and repository path you used in the attribute condition. Exact principal strings must match your pool ID and attribute names.

---

## 8. GitHub Actions workflow values

In your workflow (or Terraform variables), you typically set:

- **Workload identity provider** resource name:

  ```text
  projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github
  ```

- **Service account email:** `github-sa@PROJECT_ID.iam.gserviceaccount.com`

Use the official **`google-github-actions/auth`** action with `workload_identity_provider` and `service_account` — see [Authenticate to Google Cloud from GitHub Actions](https://github.com/google-github-actions/auth).

---

## Quick checklist

- [ ] Service account `github-sa` created with required IAM roles on the **project** (or folders) where Terraform runs.
- [ ] WIF pool `github-pool` created.
- [ ] OIDC provider `github` with issuer `https://token.actions.githubusercontent.com`.
- [ ] Attribute mappings include `google.subject` ← `assertion.sub` and `attribute.repository` ← `assertion.repository`.
- [ ] Attribute condition limits `assertion.repository` to your real `owner/repo`.
- [ ] `github-sa` has **Grant access** for the correct **principal / principalSet** with **Workload Identity User** and/or **Service Account Token Creator** as required by your auth action version.

---

## References

- [Workload Identity Federation with GitHub Actions](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines#github)
- [google-github-actions/auth](https://github.com/google-github-actions/auth)
