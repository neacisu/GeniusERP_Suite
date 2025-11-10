# GitHub Secrets Checklist

Acest document listează secretele necesare pentru funcționarea completă a pipeline-urilor CI/CD.

## Secrete Obligatorii

### 1. NX_CLOUD_AUTH_TOKEN
**Folosit în**: `.github/workflows/ci.yml` (pasul "Connect to Nx Cloud")  
**Scop**: Conectarea la Nx Cloud pentru remote caching  
**Cum se obține**: 
1. Accesează [Nx Cloud](https://nx.app/)
2. Creează un workspace sau folosește unul existent
3. Copiază token-ul de acces din Settings → Access Tokens

**Cum se configurează**:
```bash
# În GitHub repository:
Settings → Secrets and variables → Actions → New repository secret
Name: NX_CLOUD_AUTH_TOKEN
Value: [token-ul tău aici]
```

**Note**: Workflow-urile folosesc **pnpm v10** (ultima versiune LTS). Asigură-te că versiunea locală este compatibilă.

**Status**: ⬜ Neconfigurat / ✅ Configurat

---

### 2. GH_PAT_TOKEN
**Folosit în**: `.github/workflows/release.yml` (pasul "Create Release Pull Request or Publish")  
**Scop**: Permite workflow-ului să creeze commit-uri și PR-uri de release  
**Cum se obține**:
1. Accesează [GitHub Settings → Developer Settings → Personal Access Tokens](https://github.com/settings/tokens)
2. Generează un **Classic Token** cu următoarele permisiuni:
   - `repo` (Full control of private repositories)
   - `write:packages` (Upload packages to GitHub Package Registry)
3. Copiază token-ul (îl vei vedea o singură dată!)

**Cum se configurează**:
```bash
# În GitHub repository:
Settings → Secrets and variables → Actions → New repository secret
Name: GH_PAT_TOKEN
Value: [token-ul tău personal]
```

**⚠️ IMPORTANT**: Nu folosi `GITHUB_TOKEN` implicit pentru acest pas, deoarece nu va declanșa alte workflow-uri.

**Status**: ⬜ Neconfigurat / ✅ Configurat

---

### 3. NPM_TOKEN
**Folosit în**: `.github/workflows/release.yml` (pasul "Create Release Pull Request or Publish")  
**Scop**: Publicarea pachetelor pe npm registry  
**Cum se obține**:
1. Accesează [npmjs.com](https://www.npmjs.com/) și loghează-te
2. Mergi la Account Settings → Access Tokens
3. Generează un **Automation Token** (recomandat pentru CI/CD)

**Cum se configurează**:
```bash
# În GitHub repository:
Settings → Secrets and variables → Actions → New repository secret
Name: NPM_TOKEN
Value: [token-ul npm]
```

**Alternativă pentru registry privat**:
Dacă folosești un registry privat (ex: GitHub Packages, Verdaccio), înlocuiește cu token-ul corespunzător.

**Status**: ⬜ Neconfigurat / ✅ Configurat

---

## Secrete Opționale

### DOCKER_REGISTRY_TOKEN
**Folosit în**: Workflow-uri Docker (dacă folosiți alt registry decât GHCR)  
**Scop**: Autentificare la registrul Docker personalizat  
**Status**: ⬜ Nu este necesar / ✅ Configurat

---

## Verificare Automată

Pentru a verifica dacă secretele sunt configurate (fără a le dezvălui valorile), poți rula:

```bash
cd /var/www/GeniusSuite
gh secret list
```

**Output așteptat**:
```
NX_CLOUD_AUTH_TOKEN    Updated YYYY-MM-DD
GH_PAT_TOKEN           Updated YYYY-MM-DD
NPM_TOKEN              Updated YYYY-MM-DD
```

---

## Troubleshooting

### Eroare: "NX_CLOUD_AUTH_TOKEN" not found
**Soluție**: Verifică că secretul este setat exact cu numele `NX_CLOUD_AUTH_TOKEN` (case-sensitive).

### Eroare: "refusing to allow a Personal Access Token to create or update workflow"
**Soluție**: 
1. Asigură-te că PAT-ul are permisiunea `workflow`
2. Sau, dacă nu vrei să acorzi permisiunea `workflow`, elimină această restricție din repository settings

### Publicarea pe npm eșuează cu "401 Unauthorized"
**Soluție**: 
1. Verifică că `NPM_TOKEN` este valid și nu a expirat
2. Asigură-te că token-ul are permisiuni de publicare (`publish`)
3. Verifică că numele pachetelor din `package.json` nu sunt rezervate

---

## Securitate

⚠️ **NU comite niciodată secrete în cod!**
- Secretele trebuie configurate DOAR în GitHub Settings
- Dacă un secret a fost compromis, revocă-l imediat și generează unul nou
- Folosește token-uri cu permisiuni minime necesare (principiul least privilege)

---

## Data ultimei verificări

**Ultima verificare**: ___________  
**Verificat de**: ___________  
**Toate secretele configurate**: ⬜ Da / ⬜ Nu

