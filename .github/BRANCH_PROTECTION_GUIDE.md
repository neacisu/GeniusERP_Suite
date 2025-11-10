# Ghid Configurare Branch Protection Rules

Acest document descrie configurarea regul branch protection pentru `master`, `staging` și `dev`.

## ⚠️ IMPORTANT

Branch protection rules **NU pot fi configurate prin cod** în repository-uri standard. Trebuie configurate manual prin GitHub UI sau prin GitHub API/CLI.

---

## Configurare prin GitHub UI

### Acces Rapid

1. Mergi la: `https://github.com/neacisu/GeniusSuite/settings/branches`
2. SAU: Repository → Settings → Branches → Branch protection rules

---

## 🔒 Protecția pentru `master` (Production)

### Configurare Pas cu Pas

**Click pe "Add rule" sau "Add branch protection rule"**

#### 1. Branch name pattern
```
master
```

#### 2. Protect matching branches

✅ **Require a pull request before merging**
- ✅ Require approvals: **2** (minim două aprobare)
- ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ Require review from Code Owners
- ❌ Require approval of the most recent reviewable push

✅ **Require status checks to pass before merging**
- ✅ Require branches to be up to date before merging
- **Status checks obligatorii**:
  - `validate` (din CI Validation workflow)
  - `changeset-check` (din Changeset Bot workflow)
  - Orice alte check-uri custom

✅ **Require conversation resolution before merging**

✅ **Require signed commits** (opțional, dar recomandat)

✅ **Require linear history** (opțional, pentru clean history)

✅ **Do not allow bypassing the above settings**
- ⚠️ Nu permite administratorilor să bypass protecțiile

❌ **Allow force pushes** - STRICT DISABLED

❌ **Allow deletions** - STRICT DISABLED

#### 3. Rules applied to everyone including administrators

✅ **Include administrators** - Aplicăle și pentru admini

#### 4. Restrict pushes (Opțional)

- Poți restricționa cine poate face push direct pe master
- Recomandat: Nimeni nu ar trebui să poată push direct

---

## 🟡 Protecția pentru `staging` (Pre-production)

**Click pe "Add rule"**

#### 1. Branch name pattern
```
staging
```

#### 2. Protect matching branches

✅ **Require a pull request before merging**
- ✅ Require approvals: **1** (o aprobare suficientă pentru staging)
- ✅ Dismiss stale pull request approvals when new commits are pushed
- ❌ Require review from Code Owners (opțional pentru staging)

✅ **Require status checks to pass before merging**
- ✅ Require branches to be up to date before merging
- **Status checks obligatorii**:
  - `validate` (CI Validation)
  - `changeset-check` (Changeset Bot)

✅ **Require conversation resolution before merging**

❌ **Require signed commits** (opțional)

❌ **Require linear history** (opțional)

✅ **Do not allow bypassing the above settings**

❌ **Allow force pushes** - DISABLED

❌ **Allow deletions** - DISABLED

---

## 🟢 Protecția pentru `dev` (Development)

**Click pe "Add rule"**

#### 1. Branch name pattern
```
dev
```

#### 2. Protect matching branches

✅ **Require a pull request before merging** (opțional pentru dev)
- Require approvals: **0** (nu este necesar pentru dev, dar recomandat **1**)
- ✅ Dismiss stale pull request approvals when new commits are pushed

✅ **Require status checks to pass before merging**
- ❌ Require branches to be up to date before merging (prea restrictiv pentru dev)
- **Status checks obligatorii**:
  - `validate` (CI Validation)

❌ **Require conversation resolution before merging** (prea restrictiv)

❌ **Require signed commits** (opțional)

❌ **Require linear history** (opțional)

❌ **Do not allow bypassing the above settings** (permitem bypass pentru dev)

❌ **Allow force pushes** - DISABLED (chiar și pe dev, evită confuzie)

❌ **Allow deletions** - DISABLED

---

## Configurare prin GitHub CLI

Poți automatiza configurarea folosind GitHub CLI:

```bash
# Instalează gh CLI
# https://cli.github.com/

# Autentifică-te
gh auth login

# Configurare master
gh api repos/neacisu/GeniusSuite/branches/master/protection \
  --method PUT \
  --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["validate", "changeset-check"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 2
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
EOF

# Configurare staging
gh api repos/neacisu/GeniusSuite/branches/staging/protection \
  --method PUT \
  --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["validate", "changeset-check"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
EOF

# Configurare dev
gh api repos/neacisu/GeniusSuite/branches/dev/protection \
  --method PUT \
  --input - <<EOF
{
  "required_status_checks": {
    "strict": false,
    "contexts": ["validate"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "required_approving_review_count": 0
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

---

## Configurare prin Terraform (pentru IaC)

```hcl
resource "github_branch_protection" "master" {
  repository_id = "GeniusSuite"
  pattern       = "master"

  required_status_checks {
    strict   = true
    contexts = ["validate", "changeset-check"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 2
  }

  enforce_admins                  = true
  require_conversation_resolution = true
  require_signed_commits          = false
  allow_force_pushes             = false
  allow_deletions                = false
}

resource "github_branch_protection" "staging" {
  repository_id = "GeniusSuite"
  pattern       = "staging"

  required_status_checks {
    strict   = true
    contexts = ["validate", "changeset-check"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = 1
  }

  enforce_admins                  = true
  require_conversation_resolution = true
  allow_force_pushes             = false
  allow_deletions                = false
}

resource "github_branch_protection" "dev" {
  repository_id = "GeniusSuite"
  pattern       = "dev"

  required_status_checks {
    strict   = false
    contexts = ["validate"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = 0
  }

  allow_force_pushes = false
  allow_deletions    = false
}
```

---

## Verificare Configurare

După configurare, verifică:

```bash
# Verifică protecțiile pentru master
gh api repos/neacisu/GeniusSuite/branches/master/protection | jq

# Verifică protecțiile pentru staging
gh api repos/neacisu/GeniusSuite/branches/staging/protection | jq

# Verifică protecțiile pentru dev
gh api repos/neacisu/GeniusSuite/branches/dev/protection | jq
```

---

## Troubleshooting

### "Required status checks not found"

**Cauză**: Status check-urile (`validate`, `changeset-check`) nu au rulat încă pe branch.

**Soluție**:
1. Creează un PR de test pe fiecare branch
2. Așteaptă ca workflow-urile să ruleze
3. După ce rulează o dată, poți adăuga status check-urile în protecții

### "Cannot merge: Requires review"

**Normal**: Aceasta este comportamentul așteptat pentru `master` și `staging`.

### "Cannot merge: Branch is out of date"

**Normal**: Trebuie să faci rebase sau merge cu branch-ul țintă.

```bash
git pull origin master --rebase
git push --force-with-lease
```

---

## Best Practices

1. ✅ **Configurează protecțiile IMEDIAT** după crearea branch-urilor
2. ✅ **Testează** configurarea cu un PR dummy
3. ✅ **Documentează** orice excepții de la reguli
4. ✅ **Revizuiește** periodic regulile (trimestrial)
5. ✅ **Folosește CODEOWNERS** pentru review automat (vezi TODO 11)

---

## Checklist Configurare

- [ ] Branch protection configurat pentru `master`
- [ ] Branch protection configurat pentru `staging`
- [ ] Branch protection configurat pentru `dev`
- [ ] Status checks verificate și funcționale
- [ ] CODEOWNERS file creat (vezi TODO 11)
- [ ] Echipa informată despre regulile noi
- [ ] Documentație actualizată

---

**Data configurării**: ___________  
**Configurat de**: ___________  
**Toate regulile active**: ⬜ Da / ⬜ Nu

