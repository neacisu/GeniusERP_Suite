# Configurare Nx Cloud (Opțional)

Nx Cloud oferă **remote caching distribuit** pentru task-urile Nx, reducând semnificativ timpul de build în CI/CD.

## Status Actual

⚠️ **Nx Cloud nu este configurat momentan în acest monorepo.**

Pipeline-ul CI va funcționa perfect și fără Nx Cloud, dar fiecare run va executa toate task-urile affected de la zero.

---

## Beneficii Nx Cloud

✅ **Remote Caching**: Rezultatele de build/test/lint sunt partajate între dezvoltatori și CI  
✅ **Distributed Task Execution**: Rulează task-uri în paralel pe mai multe mașini  
✅ **Insights**: Dashboard detaliat cu metrici de performanță  
✅ **Cache Hit Rate**: Vizualizare procentaj cache hits vs. misses

### Reducere Timp (Exemplu)

| Scenari | Fără Nx Cloud | Cu Nx Cloud |
|---------|---------------|-------------|
| PR cu 2 pachete modificate | ~5-10 min | ~2-3 min |
| PR fără modificări de cod | ~5-10 min | ~30 sec |
| Rebuild complet (master) | ~15-20 min | ~5-8 min |

---

## Cum să Configurezi Nx Cloud

### Pasul 1: Creează un Workspace Nx Cloud

1. Accesează [https://nx.app/](https://nx.app/)
2. Loghează-te cu contul GitHub
3. Creează un nou workspace:
   - Nume: `GeniusSuite` (sau alt nume descriptiv)
   - Link repository: `neacisu/GeniusSuite`

### Pasul 2: Obține Access Token

1. În dashboard-ul Nx Cloud, mergi la **Settings → Access Tokens**
2. Creează un nou token:
   - Nume: `CI/CD Token`
   - Permisiuni: `Read & Write`
3. **Copiază token-ul** (îl vei vedea o singură dată!)

### Pasul 3: Configurează Secretul GitHub

```bash
# Folosind GitHub CLI
gh secret set NX_CLOUD_AUTH_TOKEN --body "YOUR_TOKEN_HERE"

# SAU manual în GitHub:
# Repository → Settings → Secrets and variables → Actions → New repository secret
# Name: NX_CLOUD_AUTH_TOKEN
# Value: [token-ul tău]
```

### Pasul 4: Conectează Proiectul Local

```bash
cd /var/www/GeniusSuite

# Conectează workspace-ul
pnpm exec nx connect

# Urmează instrucțiunile interactive și folosește token-ul de mai sus
```

Aceasta va modifica `nx.json` și va adăuga:

```json
{
  "nxCloudAccessToken": "YOUR_TOKEN_HERE"
}
```

⚠️ **IMPORTANT**: După conectare, șterge token-ul din `nx.json` și lasă doar configurația de bază:

```json
{
  "nxCloudId": "YOUR_WORKSPACE_ID"
}
```

Token-ul trebuie să rămână **DOAR** în secretele GitHub.

### Pasul 5: Comite Modificările

```bash
git add nx.json
git commit -m "chore: configure Nx Cloud workspace"
git push origin dev
```

### Pasul 6: Verifică Funcționarea

1. Creează un PR de test
2. Verifică în **GitHub Actions** că pasul "Connect to Nx Cloud" **nu** mai este skipped
3. Accesează dashboard-ul Nx Cloud și verifică că run-ul apare în listă

---

## Configurare Avansată

### Cache Read-Only pentru PR-uri din Fork-uri

Pentru a preveni atacuri prin PR-uri malițioase care ar putea corupe cache-ul:

```yaml
# În .github/workflows/ci.yml

- name: Connect to Nx Cloud
  if: ${{ secrets.NX_CLOUD_AUTH_TOKEN != '' }}
  run: |
    if [[ "${{ github.event.pull_request.head.repo.full_name }}" != "${{ github.repository }}" ]]; then
      export NX_CLOUD_NO_CACHE_WRITE=true
    fi
    pnpm exec nx-cloud start-ci-run
  env:
    NX_CLOUD_AUTH_TOKEN: ${{ secrets.NX_CLOUD_AUTH_TOKEN }}
```

### Distributed Task Execution

Pentru proiecte foarte mari, poți activa execuția distribuită:

```yaml
# În .github/workflows/ci.yml

jobs:
  validate:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        agent: [1, 2, 3, 4]  # 4 agenți paraleli
    steps:
      # ... pașii existenți ...

      - name: Start Nx Cloud agents
        run: pnpm exec nx-cloud start-agent
```

Documentație completă: [https://nx.dev/ci/features/distribute-task-execution](https://nx.dev/ci/features/distribute-task-execution)

---

## Troubleshooting

### Eroare: "Failed to connect to Nx Cloud"

**Cauză**: Token-ul este invalid sau expirat.

**Soluție**:
1. Regenerează token-ul din Nx Cloud Dashboard
2. Actualizează secretul `NX_CLOUD_AUTH_TOKEN` în GitHub

### Cache-ul nu se folosește

**Cauză**: Input-urile Nx nu sunt configurate corect.

**Soluție**:
Verifică `targetDefaults` în `nx.json`:

```json
{
  "targetDefaults": {
    "build": {
      "cache": true,
      "inputs": ["default", "^default"]
    }
  }
}
```

### "This run is using local caching"

**Cauză**: Pasul "Connect to Nx Cloud" nu a rulat.

**Soluție**:
1. Verifică că secretul `NX_CLOUD_AUTH_TOKEN` este setat
2. Verifică că condiția `if` din workflow nu blochează execuția

---

## Alternative la Nx Cloud

Dacă nu dorești să folosești Nx Cloud (service managed), poți configura propriul sistem de caching distribuit:

### Opțiunea 1: Local Cache cu GitHub Actions Cache

Adaugă în `ci.yml`:

```yaml
- name: Cache Nx
  uses: actions/cache@v4
  with:
    path: node_modules/.cache/nx
    key: nx-${{ runner.os }}-${{ hashFiles('pnpm-lock.yaml') }}-${{ github.sha }}
    restore-keys: |
      nx-${{ runner.os }}-${{ hashFiles('pnpm-lock.yaml') }}-
      nx-${{ runner.os }}-
```

⚠️ **Limitări**:
- Cache limitat la 10 GB per repository
- Nu partajează cache între branch-uri diferite
- Nu oferă insights sau analytics

### Opțiunea 2: Self-hosted Nx Cloud

Nx Cloud poate fi hostat on-premise:
- [Documentație oficial](https://nx.dev/ci/intro/tutorials/circle#self-hosted-nx-cloud)
- Necesită infrastructură dedicată

---

## Status Configurare

- [ ] Workspace Nx Cloud creat
- [ ] Access Token generat
- [ ] Secret `NX_CLOUD_AUTH_TOKEN` configurat în GitHub
- [ ] Workspace conectat local (`nx connect`)
- [ ] Token șters din `nx.json`
- [ ] Modificări comisionate
- [ ] Verificat funcționarea pe un PR de test

---

**Configurare recomandată**: ✅ **Da** (pentru proiecte cu >5 dezvoltatori sau >20 pachete)  
**Configurare necesară**: ❌ **Nu** (pipeline-ul funcționează și fără Nx Cloud)

**Decizie**: ⬜ Configurăm Nx Cloud / ⬜ Rămânem cu caching local

