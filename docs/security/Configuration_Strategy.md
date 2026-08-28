# Analiza Strategie Configurare: De la .env la Zero Trust

**Data:** 21 Noiembrie 2025
**Referință:** F0.5.1
**Status:** Aprobat pentru implementare

## 1. Introducere

Acest document fundamentează decizia arhitecturală de a migra gestionarea secretelor din suita GeniusERP de la fișiere statice `.env` la o soluție dinamică bazată pe OpenBao. Analiza se bazează pe auditul curent (`docs/ENV-AUDIT-REPORT.md`) și pe standardele definite în `Plan/Strategii de Fișiere.env și Porturi.md`.

## 2. Auditul Situației Curente

Conform raportului de audit din 13 noiembrie 2025, suita GeniusERP utilizează un model hibrid de configurare, bazat pe fișiere `.env` distribuite.

### 2.1 Constatări Cheie

- **Fragmentare:** Există 25 de fișiere `.env` identificate, dar naming convention-ul este inconsistent (ex: `.env.numeriqo` vs `.numeriqo.env`).
- **Lipsă de Standardizare:** 18 fișiere de configurare necesare (pentru infrastructură și Control Plane) lipsesc complet.
- **Riscuri de Securitate:**
   > - **Stocare pe Disk:** Secretele (parole DB, chei API) sunt stocate în clar pe disk-ul serverelor.
   > - **Rotație Dificilă:** Schimbarea unei parole de bază de date necesită editarea manuală a fișierelor pe toate serverele și restartarea containerelor.
   > - **Lipsă Audit:** Nu există nicio vizibilitate asupra cine și când a accesat un fișier `.env`.

## 3. Analiza de Risc (.env Vector)

Deși fișierele `.env` sunt excluse din Git (conform `.gitignore`), ele reprezintă un vector de atac semnificativ în contextul unei aplicații Enterprise.

### 3.1 Vectori de Atac Identificați

1. **Compromitere Server:** Dacă un atacator obține acces la sistemul de fișiere (ex: prin LFI - Local File Inclusion), poate citi toate secretele instantaneu.
2. **Backup-uri Neintenționate:** Fișierele `.env` pot fi incluse accidental în backup-uri de sistem necriptate.
3. **Eroare Umană:** Riscul de a comite accidental un fișier `.env` (sau o copie a acestuia) rămâne ridicat, mai ales în echipe mari.
4. **Secret Sprawl:** Aceleași secrete (ex: `SUITE_DB_ADMIN_PASSWORD`) sunt duplicate în multiple fișiere, crescând suprafața de atac.

## 4. Strategia Zero Trust (OpenBao)

Pentru a mitiga aceste riscuri, GeniusERP adoptă o strategie "Zero Trust" pentru secrete.

### 4.1 Principii

- **Niciun Secret pe Disk:** Aplicațiile nu vor mai citi fișiere `.env` în producție.
- **Injecție la Runtime:** Secretele sunt injectate direct în procesul aplicației (în memorie) de către un agent securizat.
- **Identitate, nu Parole:** Aplicațiile se autentifică la OpenBao folosind identitatea lor (ex: Kubernetes Service Account sau AppRole), nu o parolă partajată.
- **Secrete Efemere:** Acolo unde este posibil (ex: PostgreSQL), credențialele sunt generate dinamic și au o durată de viață scurtă (TTL).

### 4.2 Clasificarea Datelor: Config vs. Secret

Este crucială distincția clară între ce rămâne în Git/Env și ce se mută în OpenBao.

| Categorie | Definiție | Exemple | Stocare |
| :--- | :--- | :--- | :--- |
| **Configurație (Non-Sensibilă)** | Date necesare rulării care nu compromit securitatea dacă sunt publice. | `PORT`, `NODE_ENV`, `LOG_LEVEL`, `PUBLIC_URL` | Git / Dockerfile / ConfigMaps |
| **Secret (Sensibil)** | Date care permit accesul la resurse protejate sau decriptarea datelor. | `DB_PASSWORD`, `STRIPE_SECRET_KEY`, `JWT_SECRET`, `OIDC_CLIENT_SECRET` | **OpenBao** (exclusiv) |
| **Secret Derivat** | Date generate automat pe baza altor secrete. | `DATABASE_URL` (când conține parola) | **OpenBao** (Templating) |

## 5. Plan de Tranziție

Tranziția se va face gradual, conform planului F0.5:

1. **Faza 1-2:** Centralizarea secretelor statice în OpenBao KV engine (migrare 1:1).
2. **Faza 3:** Activarea secretelor dinamice pentru baza de date.
3. **Faza 4:** Eliminarea completă a fișierelor `.env` din producție și utilizarea `node-openbao` base image.

## 6. Concluzie

Menținerea status quo-ului (.env files) este incompatibilă cu cerințele de securitate ale GeniusERP. Implementarea OpenBao nu este doar o îmbunătățire tehnologică, ci o necesitate strategică pentru a asigura integritatea și confidențialitatea datelor clienților.
