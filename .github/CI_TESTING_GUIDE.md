# Ghid de Testare CI/CD Pipeline

Acest document descrie cum să testezi pipeline-urile CI/CD după configurare.

## Pregătire pentru Testare

### 1. Verifică că toate secretele sunt configurate

Consultă [SECRETS_CHECKLIST.md](./SECRETS_CHECKLIST.md) pentru lista completă de secrete necesare.

```bash
# Verifică secretele configurate
gh secret list
```

### 2. Verifică structura branch-urilor

```bash
cd /var/www/GeniusSuite
git branch -a

# Output așteptat:
# * dev
#   master
#   staging
#   remotes/origin/dev
#   remotes/origin/master
#   remotes/origin/staging
```

---

## Test 1: Pipeline CI (Validare PR)

### Scop
Testează workflow-ul `ci.yml` care rulează la fiecare Pull Request către `master`, `staging` sau `dev`.

### Pași

#### 1.1. Creează un branch de test

```bash
cd /var/www/GeniusSuite
git checkout dev
git pull origin dev
git checkout -b test/ci-pipeline-validation
```

#### 1.2. Fă o modificare simplă (test)

```bash
# Creează un fișier de test
echo "# CI Test" > .github/CI_TEST.md
git add .github/CI_TEST.md
git commit -m "test(ci): verificare pipeline CI"
```

#### 1.3. Push branch-ul

```bash
git push origin test/ci-pipeline-validation
```

#### 1.4. Creează un Pull Request

```bash
# Folosind GitHub CLI
gh pr create \
  --base dev \
  --head test/ci-pipeline-validation \
  --title "test(ci): Verificare pipeline CI" \
  --body "PR de test pentru validarea workflow-ului CI. Va fi închis după verificare."

# SAU manual pe GitHub:
# https://github.com/neacisu/GeniusSuite/compare/dev...test/ci-pipeline-validation
```

#### 1.5. Verifică execuția workflow-ului

```bash
# Vizualizează status-ul workflow-urilor
gh pr checks

# SAU vizualizează în browser
gh pr view --web
```

### Rezultate Așteptate

✅ **Success Criteria:**

1. Workflow-ul "CI Validation" apare în tab-ul "Actions"
2. Job-ul `validate` se execută cu succes
3. Toate pașii sunt verzi:
   - ✅ Checkout repository
   - ✅ Setup Node.js
   - ✅ Setup pnpm
   - ✅ Setup pnpm cache
   - ✅ Install dependencies
   - ✅ Set Nx SHAs
   - ✅ Connect to Nx Cloud (dacă este configurat)
   - ✅ Check formatting (affected)
   - ✅ Lint affected projects
   - ✅ Test affected projects
   - ✅ Build affected projects

4. PR-ul poate fi merge-uit

#### 1.6. Cleanup

```bash
# Închide PR-ul
gh pr close test/ci-pipeline-validation --delete-branch

# SAU manual
git checkout dev
git branch -D test/ci-pipeline-validation
git push origin --delete test/ci-pipeline-validation
```

---

## Test 2: Changeset Bot

### Scop
Testează workflow-ul `changeset-bot.yml` care verifică prezența changesets în PR-uri.

### Pași

#### 2.1. Creează un branch și modifică un pachet

```bash
cd /var/www/GeniusSuite
git checkout dev
git checkout -b test/changeset-bot

# Modifică un fișier într-un pachet (ex: shared/common)
echo "// Test change" >> shared/common/README.md
git add shared/common/README.md
git commit -m "test: modificare pentru testare changeset bot"
git push origin test/changeset-bot
```

#### 2.2. Creează PR fără changeset

```bash
gh pr create \
  --base dev \
  --head test/changeset-bot \
  --title "test: Verificare changeset bot (fără changeset)" \
  --body "Acest PR ar trebui să eșueze deoarece lipsește changeset-ul."
```

### Rezultate Așteptate (Test Negativ)

❌ **Așteptăm eșec:**
1. Workflow-ul "Changeset Bot" rulează
2. Job-ul `changeset-check` detectează modificări în pachete
3. Job-ul adaugă un comentariu pe PR
4. Job-ul **EȘUEAZĂ** cu mesajul: "Pachet modificat fără fișier .changeset"

#### 2.3. Adaugă changeset și testează din nou

```bash
# Adaugă un changeset
pnpm exec changeset

# Urmează instrucțiunile interactive:
# - Alege pachetele modificate (shared/common)
# - Alege tipul de versiune (patch/minor/major)
# - Adaugă un mesaj descriptiv

# Comite changeset-ul
git add .changeset/
git commit -m "chore: add changeset pentru shared/common"
git push origin test/changeset-bot
```

### Rezultate Așteptate (Test Pozitiv)

✅ **Așteptăm succes:**
1. Workflow-ul "Changeset Bot" rulează din nou
2. Job-ul detectează fișierul changeset
3. Job-ul **TRECE** cu succes

#### 2.4. Cleanup

```bash
gh pr close test/changeset-bot --delete-branch
```

---

## Test 3: Deploy Staging

### Scop
Testează workflow-ul `deploy-staging.yml` care construiește imagini Docker la push pe `staging`.

### Pași

#### 3.1. Merge un PR în staging

```bash
# Presupunem că avem deja un PR aprobat pe dev
# Merge-uim dev în staging

git checkout staging
git pull origin staging
git merge dev --no-ff -m "chore: merge dev into staging pentru test deploy"
git push origin staging
```

#### 3.2. Verifică workflow-ul

```bash
# Vizualizează workflow-urile în desfășurare
gh run list --workflow=deploy-staging.yml --limit 5

# Urmărește execuția în timp real
gh run watch
```

### Rezultate Așteptate

✅ **Success Criteria:**
1. Workflow-ul "Deploy to Staging" se declanșează automat
2. Job-ul `docker-deploy-staging` se execută
3. Imaginile Docker pentru aplicațiile afectate sunt construite
4. Imaginile sunt push-uite pe GHCR cu tag-ul `staging`

**Verificare imagini**:
```bash
# Verifică imaginile pe GHCR
# https://github.com/neacisu?tab=packages
```

---

## Test 4: Release Workflow

### Scop
Testează workflow-ul `release.yml` care publică pachete pe npm.

### ⚠️ ATENȚIE
Acest test va publica efectiv pachete pe npm! Rulează doar când ești gata pentru un release real.

### Pași

#### 4.1. Asigură-te că ai changesets pe master

```bash
git checkout master
git pull origin master

# Verifică changesets-urile
pnpm exec changeset status
```

#### 4.2. Merge staging în master

```bash
# Creează un PR staging → master
git checkout staging
git pull origin staging

gh pr create \
  --base master \
  --head staging \
  --title "release: Prepare for production release" \
  --body "Merge staging în master pentru release."

# Aprobă și merge-uiește PR-ul (manual sau cu gh pr merge)
# SAU direct:
git checkout master
git merge staging --no-ff -m "release: merge staging into master"
git push origin master
```

#### 4.3. Verifică workflow-ul

```bash
gh run list --workflow=release.yml --limit 5
gh run watch
```

### Rezultate Așteptate

✅ **Success Criteria:**
1. Workflow-ul "Release Packages" se declanșează la push pe master
2. Validările trec (format, lint, test, build)
3. `changesets/action` creează:
   - Commit-uri de versionare (actualizează `package.json` și `CHANGELOG.md`)
   - **SAU** publică pachetele direct pe npm (dacă există changesets)

---

## Test 5: Deploy Production

### Scop
Testează workflow-ul `deploy-prod.yml` care construiește imagini Docker la release.

### Pași

#### 5.1. Creează un release GitHub

```bash
# După ce release.yml a rulat și changesets au fost procesate
# Creează un tag și release

git checkout master
git pull origin master

# Creează un tag (versiunea din package.json)
VERSION=$(node -p "require('./package.json').version")
git tag -a "v$VERSION" -m "Release v$VERSION"
git push origin "v$VERSION"

# Creează release pe GitHub
gh release create "v$VERSION" \
  --title "Release v$VERSION" \
  --notes "Release automat generat de changesets" \
  --latest
```

#### 5.2. Verifică workflow-ul

```bash
gh run list --workflow=deploy-prod.yml --limit 5
gh run watch
```

### Rezultate Așteptate

✅ **Success Criteria:**
1. Workflow-ul "Deploy to Production" se declanșează la `release: published`
2. Imaginile Docker sunt construite pentru aplicațiile afectate
3. Imaginile sunt tag-uite cu versiunea release-ului (ex: `v1.0.0`)
4. Imaginile sunt push-uite pe GHCR

---

## Troubleshooting

### Workflow-ul nu se declanșează

**Cauze posibile:**
1. Branch-ul nu este protejat sau nu există
2. Workflow-ul are erori de sintaxă YAML
3. Repository-ul nu are Actions activate

**Soluție:**
```bash
# Validează sintaxa YAML
yamllint .github/workflows/*.yml

# SAU folosește un validator online
# https://www.yamllint.com/
```

### Job-ul eșuează la "Install dependencies"

**Cauze posibile:**
1. `pnpm-lock.yaml` nu este sincronizat cu `package.json`
2. Versiune incompatibilă de pnpm

**Soluție:**
```bash
# Regenerează lockfile-ul
rm pnpm-lock.yaml
pnpm install
git add pnpm-lock.yaml
git commit -m "fix: regenerate pnpm-lock.yaml"
```

### "Connect to Nx Cloud" eșuează

**Cauze posibile:**
1. `NX_CLOUD_AUTH_TOKEN` nu este configurat
2. Token-ul este invalid sau expirat

**Soluție:**
1. Verifică secretul în GitHub Settings
2. Regenerează token-ul din Nx Cloud
3. Sau comentează pasul dacă nu folosești Nx Cloud

### Imaginile Docker nu apar pe GHCR

**Cauze posibile:**
1. `GITHUB_TOKEN` nu are permisiuni `write:packages`
2. Registry-ul este configurat greșit

**Soluție:**
1. Verifică permisiunile workflow-ului în `.github/workflows/deploy-*.yml`
2. Asigură-te că `permissions: packages: write` este setat

---

## Checklist Final

După ce toate testele au fost rulate cu succes:

- [ ] CI Validation funcționează pe PR-uri
- [ ] Changeset Bot detectează și validează changesets
- [ ] Deploy Staging construiește și publică imagini
- [ ] Release workflow publică pachete pe npm
- [ ] Deploy Production tag-uiește corect imaginile
- [ ] Toate secretele sunt configurate
- [ ] Branch protection rules sunt active
- [ ] Documentația este actualizată

---

**Data ultimului test**: ___________  
**Testat de**: ___________  
**Toate testele au trecut**: ⬜ Da / ⬜ Nu

