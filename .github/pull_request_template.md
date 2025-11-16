# Pull Request

## 📝 Descriere

<!-- Descrie pe scurt ce face acest PR și de ce este necesar -->

## 🎯 Tipul Schimbării

<!-- Marchează cu [x] -->

- [ ] 🐛 Bug fix (non-breaking change care rezolvă o problemă)
- [ ] ✨ Feature nou (non-breaking change care adaugă funcționalitate)
- [ ] 💥 Breaking change (fix sau feature care ar cauza ca funcționalitatea existentă să nu mai funcționeze)
- [ ] 📚 Documentație (modificări doar în documentație)
- [ ] 🎨 Refactoring (îmbunătățiri de cod fără schimbări funcționale)
- [ ] ⚡ Performance (îmbunătățiri de performanță)
- [ ] 🧪 Test (adăugare sau corecție teste)
- [ ] 🔧 Configurare/Build (modificări în build sau configurare)
- [ ] ♻️ Chore (altceva care nu modifică src sau test files)

## 🔗 Issue-uri Legate

<!-- Dacă există issue-uri legate, link-uiește-le aici -->

Closes #
Related to #

## 📦 Pachete Afectate

<!-- Listează pachetele modificate din monorepo -->

- [ ] `shared/ui-design-system`
- [ ] `shared/common`
- [ ] `shared/auth-client`
- [ ] `cp/*` (Control Plane)
- [ ] Aplicații stand-alone
- [ ] Altele: ___________

## ✅ Checklist

### Cod

- [ ] Codul respectă standardele de stil ale proiectului (ESLint, Prettier)
- [ ] Am rulat `pnpm lint` și nu există erori
- [ ] Am rulat `pnpm format:check` și codul este formatat corect
- [ ] Am adăugat teste pentru noua funcționalitate/fix
- [ ] Toate testele trec local (`pnpm test`)
- [ ] Build-ul trece (`pnpm nx build <app>`)

### Changesets

- [ ] Am adăugat un changeset pentru modificările de pachete (`pnpm exec changeset`)
  - [ ] Am ales tipul corect de versiune (patch/minor/major)
  - [ ] Am scris o descriere clară în changeset

**IMPORTANT**: Dacă ai modificat pachete în `shared/*`, `cp/*` sau aplicații, TREBUIE să adaugi un changeset!

```bash
pnpm exec changeset
# Urmează instrucțiunile interactive
git add .changeset/
git commit -m "chore: add changeset"
```

### Documentație

- [ ] Am actualizat documentația (dacă aplicabil)
- [ ] Am actualizat README-ul (dacă aplicabil)
- [ ] Am actualizat comentariile în cod
- [ ] Am documentat API-uri noi (dacă aplicabil)

### Testare

- [ ] Am testat modificările local
- [ ] Am verificat că nu apar erori în consolă
- [ ] Am testat pe mai multe browser-e (dacă aplicabil)
- [ ] Am testat backward compatibility (dacă aplicabil)

### Securitate

- [ ] Nu există token-uri, parole sau date sensibile în cod
- [ ] Am verificat dependențele pentru vulnerabilități
- [ ] Am considerat implicațiile de securitate ale schimbărilor

## 🧪 Cum să Testezi

<!-- Descrie pașii pentru a testa schimbările -->

1. 
2. 
3. 

## 📸 Screenshots (dacă aplicabil)

<!-- Adaugă screenshot-uri pentru schimbări UI -->

**Înainte:**

**După:**

## 📊 Impact

<!-- Descrie impactul schimbărilor -->

### Performance

- [ ] Nu afectează performanța
- [ ] Îmbunătățește performanța
- [ ] Ar putea afecta performanța (detalii: _________)

### Breaking Changes

- [ ] Nu există breaking changes
- [ ] Există breaking changes (detalii mai jos)

<details>
<summary>📋 Detalii Breaking Changes</summary>

<!-- Descrie breaking changes și migrarea necesară -->

</details>

## 💭 Note Suplimentare

<!-- Orice alte informații relevante pentru reviewers -->

---

## Pentru Reviewers

### 🔍 Focus Areas

<!-- Ce ar trebui să verifice reviewers cu atenție -->

- 

### ❓ Întrebări pentru Reviewers

<!-- Întrebări specifice pentru reviewers -->

- 

---

**Merge Strategy**: 
- Pentru PR-uri către `dev`: Auto-merge disponibil cu label `ready-for-staging`
- Pentru PR-uri către `staging`/`master`: Merge manual după review complet

**CI Status**: Workflow-ul CI va rula automat. Toate verificările trebuie să treacă înainte de merge.

