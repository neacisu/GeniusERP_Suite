
# Strategie securitate F0.5: Arhitectura de Securitate, Guvernanța Configurațiilor și Managementul Secretelor pentru Suita GeniusERP

## 1. Sumar Executiv

Prezentul raport constituie documentul de referință pentru inițiativa strategică "F0.5" din cadrul proiectului GeniusERP. Obiectivul fundamental al acestei cercetări este validarea, critica constructivă și rafinarea planului de tranziție de la o arhitectură de configurare statică, bazată pe fișiere .env distribuite, către o arhitectură dinamică, centralizată și securizată, guvernată de OpenBao. Această tranziție nu este doar o actualizare tehnologică, ci o schimbare de paradigmă necesară pentru a alinia suita GeniusERP la standardele moderne de "Defense in Depth" și "Zero Trust".
Analiza aprofundată a stării curente confirmă că, deși strategia existentă de nomenclatură a fișierelor .env oferă o guvernanță excelentă și previne coliziunile de variabile într-un mediu monorepo complex, ea introduce vulnerabilități critice de securitate. Practica de a amesteca configurațiile non-sensibile (ex: porturi, domenii) cu secretele de mare valoare (ex: parole de baze de date, chei API) într-un singur artefact (fișierul .env) creează un vector de atac semnificativ. Riscul de scurgere a datelor prin sistemele de control al versiunilor (Git) este inacceptabil de ridicat, iar rotația credențialelor devine un proces manual, predispus la erori umane și fricțiune operațională.
Soluția propusă, care implică adoptarea OpenBao ca manager de secrete, implementarea modelului Sidecar pentru injecția secretelor la runtime și utilizarea autentificării OIDC (OpenID Connect) pentru pipeline-urile CI/CD, este validată ca fiind robustă și necesară. OpenBao, fiind un fork open-source al HashiCorp Vault gestionat sub egida Linux Foundation, asigură libertatea de licențiere pe termen lung, menținând în același timp compatibilitatea tehnică cu ecosistemul vast de unelte Vault.
Totuși, raportul identifică provocări tehnice majore care nu au fost detaliate suficient în planul inițial, în special problema "race condition" în orchestratorul Docker Compose, unde containerele aplicației pot porni înainte ca agentul sidecar să livreze secretele. De asemenea, se clarifică distincția critică între criptarea transparentă a datelor (TDE) la nivel de disc și criptarea la nivel de coloană (pgcrypto), recomandând o abordare stratificată.
În final, raportul detaliază o strategie hibridă clară: configurațiile non-sensibile rămân în Git pentru trasabilitate, în timp ce secretele sunt gestionate exclusiv de OpenBao și injectate efemer. Se propune o arhitectură de tip "Process Supervisor" pentru a rezolva limitările Docker Compose și se definește un set secvențial de task-uri (F0.5.x) pentru execuție.

### 1.1. Audit și Analiză de Risc (F0.5.1)

Ca parte a fazei de fundamentare, a fost redactat documentul **[Analiza Strategie Configurare](docs/security/Configuration_Strategy.md)**. Acesta corelează constatările din auditul curent (25 fișiere `.env` fragmentate, 18 lipsă) cu riscurile de securitate (stocare pe disk, lipsă audit). Documentul stabilește clar distincția între **Configurație** (Git) și **Secret** (OpenBao), fiind baza legală pentru modificările arhitecturale ulterioare.

## 2. Analiza Arhitecturală a Stării Curente și a Vectorilor de Risc

Pentru a justifica necesitatea tranziției către OpenBao, este imperativ să deconstruim arhitectura actuală a suitei GeniusERP și să analizăm modul în care deciziile de design influențează postura de securitate.

### 2.1. Modelul Hibrid de Orchestrare Docker

Arhitectura GeniusERP se bazează pe un model de orchestrare "hibrid", care reprezintă un compromis pragmatic între simplitatea dezvoltării locale și necesitatea izolării serviciilor. Acest model nu este nici o structură monolitică simplă, nici un cluster Kubernetes complet distribuit, ci o federație de contexte Docker Compose interconectate.
Sistemul este structurat pe două niveluri distincte de responsabilitate:
Orchestratorul Rădăcină (Root Orchestrator): Situat la /var/www/GeniusSuite/compose.yml, acest nivel este responsabil pentru ciclul de viață al componentelor partajate, denumite "Backing Services". Aici sunt definite persistența globală (PostgreSQL, Kafka), stiva de observabilitate (Prometheus, Grafana, Loki) și stratul de ingress (Traefik). Aceste servicii formează coloana vertebrală a infrastructurii, fiind consumate de toate aplicațiile din suită.
Orchestratorii de Aplicație (Application Orchestrators): Fiecare modul sau micro-aplicație din monorepo (de exemplu, numeriqo.app, archify.app) posedă propriul fișier de orchestrare, situat tipic în [app_name]/compose/docker-compose.yml. Această arhitectură permite dezvoltatorilor să inițieze contexte izolate, rulând doar serviciile necesare pentru o anumită sarcină, fără a încărca întreaga suită.
Implicații de Securitate: Această segregare, deși benefică pentru productivitate, introduce o complexitate semnificativă în gestionarea secretelor. Un container de aplicație (ex: numeriqo-api) pornit dintr-un subdirector trebuie să se autentifice la o bază de date (ex: postgres-global) pornită de orchestratorul rădăcină. În prezent, "liantul" care permite această conexiune este fișierul .env. Acesta trebuie să existe fizic în ambele contexte sau să fie duplicat, crescând suprafața de atac. Dacă un dezvoltator compromite fișierul .env al aplicației numeriqo, el expune implicit credențialele care permit accesul la infrastructura partajată gestionată de root.

### 2.2. Strategia Actuală .env: O Analiză Forensică

Strategia curentă de configurare se bazează pe fișiere text care conțin perechi cheie-valoare. Documentația existentă evidențiază o disciplină riguroasă în ceea ce privește nomenclatura, dar o vulnerabilitate fundamentală în ceea ce privește stocarea.

#### 2.2.1. Puncte Forte: Guvernanța Nomenclaturii

Standardizarea numelor variabilelor este un succes arhitectural care trebuie păstrat în era OpenBao. Convenția `<PREFIX>_<CATEGORIE>_<NUME>` (de exemplu, CP_IDT_AUTH_JWT_SECRET sau NUMQ_DB_PASS) previne coliziunile în spațiul global de variabile de mediu. Într-un sistem distribuit unde zeci de containere pot partaja rețele sau volume, un nume generic precum DB_PASSWORD ar fi dezastruos, ducând la situații în care aplicația archify s-ar conecta accidental la baza de date a aplicației numeriqo. Utilizarea prefixelor specifice componentei (ex: NUMQ_ pentru Numeriqo, CP_IDT_ pentru Identity Control Plane) asigură claritate și izolare logică.

#### 2.2.2. Puncte Slabe: Amestecul Configurațiilor cu Secretele

Vulnerabilitatea critică identificată în task-ul F0.5.1 este lipsa de separare între "Configurație" și "Secret".
Configurația (ex: NUMQ_APP_PORT=6750, SUITE_APP_DOMAIN=geniuserp.app) reprezintă date non-sensibile, necesare la build-time sau run-time pentru a defini comportamentul aplicației. Acestea nu oferă acces la date protejate și sunt adesea cunoștințe publice (porturile de ascultare, domeniile publice).
Secretele (ex: NUMQ_DB_PASS=x8z..., STRIPE_SECRET_KEY=sk_...) sunt cheile regatului. Compromiterea lor permite accesul neautorizat, exfiltrarea datelor sau impersonarea serviciilor.
În prezent, ambele categorii locuiesc în același fișier .numeriqo.env. Această coabitare forțează echipa de DevOps să trateze întregul fișier ca fiind "toxic". Nu poate fi comis în Git, ceea ce complică procesele de CI/CD (care au nevoie de porturi pentru teste) și onboarding-ul noilor dezvoltatori (care trebuie să primească aceste fișiere prin canale securizate, adesea improvizate). Mai mult, riscul de eroare umană — un git add. neglijent urmat de un commit — este o amenințare constantă. Un singur fișier comis din greșeală invalidează securitatea întregului mediu și necesită o rotație imediată a tuturor credențialelor, un proces costisitor și disruptiv.

### 2.3. Topologia de Rețea Zero-Trust

Documentația menționează angajamentul pentru o topologie de rețea "Zero Trust" în Docker, structurată pe patru zone distincte. Aceasta este o componentă critică ce trebuie integrată nativ cu strategia OpenBao.
Cele patru zone sunt:

- **Edge**: Zona expusă publicului, unde rezidă doar componentele de ingress (Traefik, API Gateway).
- **API**: Zona unde rulează logica de business a aplicațiilor (Node.js containere).
- **Backing Services**: Zona "sanctuar" unde rezidă persistența (PostgreSQL, Kafka). Această zonă nu trebuie să fie niciodată accesibilă direct din Edge.
- **Observability**: Zona de monitorizare (Prometheus, Loki), care trebuie să colecteze date din toate celelalte zone, dar să aibă drepturi limitate de interacțiune.

**Integrarea OpenBao**: În acest model, containerul OpenBao este un "Backing Service" de securitate. El trebuie plasat strategic. Dacă OpenBao ar fi accesibil din net_edge, suprafața de atac ar crește exponențial. Prin urmare, strategia F0.5 trebuie să impună ca serviciul OpenBao să fie conectat exclusiv la rețelele net_backing_services (pentru a comunica cu baza de date în vederea generării secretelor dinamice) și net_observability (pentru exportul logurilor de audit). Aplicațiile din zona API vor comunica cu OpenBao prin intermediul rețelelor interne Docker, fără ca traficul să părăsească vreodată host-ul sau să treacă prin proxy-ul public.

## 3. Evaluarea Critică a Tehnologiilor Propuse (OpenBao, Sidecar, OIDC)

Adoptarea suitei tehnologice propuse (OpenBao, Sidecar, OIDC) reprezintă o maturizare semnificativă a infrastructurii. Această secțiune analizează validitatea acestor alegeri în contextul peisajului tehnologic din 2025.

### 3.1. OpenBao vs. HashiCorp Vault: O Alegere Strategică

Decizia de a utiliza OpenBao în locul HashiCorp Vault este una fundamentată pe considerente de licențiere și sustenabilitate pe termen lung. În urma schimbării licenței HashiCorp către BSL (Business Source License), comunitatea open-source a reacționat prin crearea fork-ului OpenBao sub egida Linux Foundation.

- Avantaje Strategice: OpenBao păstrează licența MPL (Mozilla Public License) 2.0, care este aprobată de OSI (Open Source Initiative). Aceasta elimină ambiguitățile legale pentru companiile care ar putea dori să integreze soluția în produse comerciale sau să o ofere ca serviciu, evitând restricțiile anti-competiție ale BSL.

- Compatibilitate Tehnică: Cercetarea confirmă că OpenBao menține, în acest moment, o compatibilitate API strictă cu Vault. Acest lucru este crucial pentru GeniusERP, deoarece permite utilizarea ecosistemului existent de unelte Vault. De exemplu, acțiunea de GitHub hashicorp/vault-action va funcționa perfect cu un server OpenBao, deoarece protocolul de autentificare și endpoint-urile API sunt identice. Client libraries standard pentru Node.js sau Go vor funcționa fără modificări.

- Riscuri: Ca orice fork recent, există riscul divergenței pe termen lung. Totuși, funcționalitățile "core" necesare pentru GeniusERP (KV Secrets Engine, Database Secrets Engine, OIDC Auth, Policies) sunt mature și stabile, fiind moștenite din baza de cod Vault care a fost testată în producție timp de un deceniu.

- Verdict: Alegerea OpenBao este validată. Oferă funcționalitățile enterprise ale Vault (secrete dinamice, politici granulare) fără povara licențierii restrictive, fiind aliniată cu filozofia open-source a proiectului.

### 3.2. Provocarea Modelului Sidecar în Docker Compose

>> Propunerea de a utiliza un model "Sidecar" (OpenBao Agent) pentru injecția secretelor este standardul de aur în Kubernetes, dar implementarea sa în Docker Compose prezintă dificultăți tehnice majore care nu au fost suficient explorate în planul inițial. Aceasta este cea mai critică zonă de risc a planului F0.5.
>> Problema "Race Condition":
În Kubernetes, un initContainer poate fi utilizat pentru a garanta că secretele sunt randate într-un volum partajat înainte ca containerul principal al aplicației să pornească. Docker Compose nu are un concept nativ echivalent de initContainer care să blocheze pornirea altor servicii din același pod/grup.

Dacă serviciul numeriqo.app și serviciul openbao-agent sunt definite să pornească simultan (chiar și cu depends_on), există o probabilitate ridicată ca aplicația Node.js să încerce să citească fișierul .env sau să se conecteze la baza de date înainte ca agentul să fi avut timp să se autentifice la serverul OpenBao, să primească token-ul și să randeze șablonul. Rezultatul este eșecul pornirii aplicației, erori de conexiune la DB și un ciclu de restart-uri instabil.

>> Soluția Robustă: Modul "Process Supervisor":
Pentru a remedia această vulnerabilitate arhitecturală, raportul recomandă imperativ adoptarea modului Process Supervisor al agentului OpenBao, în locul modelului simplu de sidecar cu volume partajate.
În acest scenariu, structura containerului se schimbă fundamental:

- Entrypoint-ul Containerului: Nu mai este aplicația Node.js (node index.js), ci executabilul bao agent.
- Configurația Agentului: Include un bloc exec care specifică comanda de lansare a aplicației copil.
- Fluxul de Execuție:

    > - Containerul pornește, lansând Agentul OpenBao.
    > - Agentul se autentifică și descarcă secretele.
    > - Doar după ce secretele sunt pregătite, Agentul lansează procesul copil (node index.js).
    > - Secretele sunt injectate direct în variabilele de mediu ale procesului copil, fără a mai fi nevoie de scrierea lor pe disc într-un volum partajat (ceea ce este mai sigur).
    > - Agentul monitorizează ciclul de viață al aplicației și poate trimite semnale (ex: SIGTERM) pentru restartarea acesteia dacă secretele se schimbă (rotație).

Această abordare elimină complet condiția de cursă și simplifică definiția serviciilor în Docker Compose, transformând problema de coordonare distribuită într-una de ierarhie de procese locală.

### 3.3. Autentificarea OIDC pentru CI/CD

Integrarea OIDC (OpenID Connect) pentru GitHub Actions este validată ca fiind măsura corectă pentru eliminarea "Secretului Zero".
În modelul tradițional, un token de acces pe termen lung (ex: VAULT_TOKEN) trebuia stocat în GitHub Secrets pentru ca pipeline-ul să poată accesa Vault-ul. Dacă acest token era compromis, atacatorul avea acces persistent.
Prin OIDC, GitHub devine un furnizor de identitate. La rularea unui workflow, GitHub semnează criptografic un JWT care atestă identitatea job-ului (ex: "Eu sunt un job care rulează pe ramura main a repo-ului GeniusERP/suite"). OpenBao este configurat să aibă încredere în cheile publice ale GitHub și verifică acest JWT. Dacă este valid și corespunde politicilor definite (Bound Claims), OpenBao emite un token de acces cu durată scurtă de viață, specific pentru acea execuție.
Această metodă leagă securitatea de proces și de cod, nu de un artefact static, crescând semnificativ securitatea lanțului de aprovizionare software (Supply Chain Security).

### 3.4. Strategia de Criptare: pgcrypto vs. TDE

Solicitarea inițială cere validarea strategiei de criptare, menționând TDE (Transparent Data Encryption) pentru PostgreSQL 18 și pgcrypto. Analiza detaliată a capabilităților PostgreSQL 18 relevă nuanțe importante.
Realitatea TDE în PostgreSQL 18: Deși mult așteptată, funcționalitatea TDE nativă în ediția comunitară a PostgreSQL 18 este încă un subiect de dezbatere și dezvoltare activă, nefiind garantată ca o funcționalitate "core" stabilă și completă la data lansării. Soluții TDE robuste există, dar sunt oferite de obicei prin extensii sau fork-uri enterprise, cum ar fi Percona Distribution for PostgreSQL sau EDB Postgres. TDE protejează datele "at-rest" prin criptarea fișierelor de pe disc, apărând împotriva furtului fizic al serverului sau al drive-urilor de stocare. Totuși, TDE este transparent pentru motorul bazei de date; un administrator de bază de date (DBA) conectat cu drepturi depline poate vedea datele în clar.
Necesitatea pgcrypto: Pentru datele extrem de sensibile (PII - Identificatori Personali, date financiare), TDE nu este suficient. Strategia "Defense in Depth" impune criptarea la nivel de coloană folosind pgcrypto. Prin utilizarea funcțiilor precum pgp_sym_encrypt, datele sunt stocate criptat în tabele, iar cheia de decriptare nu este stocată în baza de date, ci este deținută de aplicație (injectată via OpenBao). Astfel, chiar și un atacator care obține un dump complet al bazei de date (SQL Injection sau compromiterea credențialelor de admin) nu va putea citi datele sensibile fără cheia de aplicație.
> Recomandare: Implementarea imediată a pgcrypto pentru coloanele sensibile este obligatorie. TDE trebuie tratat ca o optimizare de infrastructură (nivelul 2 de protecție) ce va fi activată odată ce suportul devine stabil în distribuția PostgreSQL utilizată, dar nu poate înlocui criptarea la nivel de aplicație pentru datele critice.

## 4. Strategia Finală: Arhitectura "Zero-Shared-State"

Pe baza analizei, definim strategia finală rafinată pentru implementarea F0.5. Aceasta se bazează pe o separare strictă a responsabilităților și pe eliminarea oricărei stări partajate nesecurizate.

### 4.1. Politica Hibridă de Configurare

Formalizăm separarea conceptelor de "Mediu" și "Acces".
Configurație (Git-Safe):
Definiție: Parametri care modelează comportamentul aplicației dar nu conferă privilegii de acces.
Exemple: HTTP_PORT, LOG_LEVEL, THEME_COLOR, FEATURE_FLAG_BETA, SERVICE_URLS, SUITE_APP_DOMAIN.
Stocare: Fișiere .env comisionate în Git (ex: .numeriqo.env).
Justificare: Aceste valori sunt necesare la build, sunt adesea publice și facilitează colaborarea. Modificarea lor nu constituie un incident de securitate.
Secrete (OpenBao-Managed):
Definiție: Orice șir de caractere care conferă autentificare, autorizare sau capacitatea de a decripta date.
Exemple: DB_PASSWORD, JWT_SECRET, STRIPE_API_KEY, OIDC_CLIENT_SECRET, PG_CRYPTO_KEY.
Stocare: OpenBao KV Engine (pentru secrete statice) și Dynamic Engines (pentru baza de date).
Injecție: La runtime, direct în memoria procesului, prin intermediul OpenBao Agent în mod Process Supervisor. Niciun secret nu atinge discul containerului de aplicație.

### 4.2. Arhitectura Tehnică a Implementării

Arhitectura va folosi următoarele componente cheie:
Server OpenBao: Container Docker self-hosted, conectat la rețele izolate, cu stocare persistentă pe volum criptat (la nivel de sistem de fișiere sau volum Docker protejat).
OpenBao Agent (Process Supervisor): Containerul principal al serviciilor de aplicație va rula imaginea Agentului, care va orchestra lansarea aplicației reale (Node.js).
Secrete Dinamice PostgreSQL: Aplicațiile nu vor mai avea parole statice pentru baza de date. Ele vor primi credențiale unice, generate la pornire, cu un TTL (Time-To-Live) scurt (ex: 1 oră). Agentul se va ocupa de reînnoirea automată a acestor credențiale cât timp aplicația rulează.
Scripturi de Inițializare: Un set de scripturi robuste pentru "Bootstrapping" va asigura că mediul de dezvoltare poate fi ridicat rapid, automatizând inițializarea și unsealing-ul OpenBao pentru dezvoltatorii locali.

## 5. Planul Detaliat de Implementare (Task-uri F0.5.x)

Această secțiune transformă strategia într-un plan de acțiune granular, gata de execuție.

### Faza 1: Fundația și Infrastructura

#### F0.5.1: Analiza Strategie Configurare (Documentare)

Scop: Formalizarea riscului. Documentul va servi ca bază legală și tehnică pentru modificările ulterioare.
Acțiune: Redactarea docs/security/F0.5-Analiza-Strategie-Config.md. Trebuie să contrasteze conveniența actuală cu riscurile de securitate, folosind exemple concrete din proiect (ex: riscul expunerii NUMQ_DB_PASS).

#### F0.5.2: Politica Hibridă Config vs. Secrete (Guvernanță)

Scop: Definirea regulilor de joc.
Acțiune: Crearea docs/security/F0.5-Politica-Config-vs-Secrete.md. Acest document va acționa ca un ghid pentru code-review. Orice PR care introduce un secret într-un fișier .env va fi respins pe baza acestei politici.

#### F0.5.3: Implementare Serviciu OpenBao (Infrastructură)

Scop: Ridicarea motorului de secrete.
Acțiune: Modificarea compose.yml rădăcină.
Adăugare serviciu openbao.
Imagine: openbao/openbao:latest (sau o imagine specifică validată).
Capabilități: IPC_LOCK pentru a preveni swap-ul memoriei pe disc (măsură critică de securitate).
Rețele: Conectare strictă la net_backing_services și net_observability. Interzicerea accesului la net_edge.
Configurare: Activarea modului server cu stocare pe fișier (în volumul gs_openbao_data).

#### F0.5.4: Automatizare Bootstrap (Scripting)

Scop: Eliminarea fricțiunii pentru dezvoltatori.
Acțiune: Crearea scripts/security/openbao-init.sh.
Scriptul verifică starea serverului.
Dacă nu este inițializat, execută bao operator init.
Salvează cheile de unseal și token-ul root într-un fișier local protejat (.secrets/keys.json), care este adăugat automat în .gitignore.
Execută automat unseal pentru a aduce serverul în stare operațională.

### Faza 2: Controlul Accesului și Migrarea Datelor

#### F0.5.5: Politici ACL (Securitate)

Scop: Implementarea "Least Privilege".
Acțiune: Definirea fișierelor .hcl în scripts/security/policies/.
Exemplu numeriqo-prod.hcl: Permite read doar pe secret/data/prod/numeriqo/* și read/write pe database/creds/numeriqo-role.
Aplicarea politicilor prin scripturi CLI.

#### F0.5.6: Inventariere Secrete (Audit)

Scop: Cartografierea completă a variabilelor.
Acțiune: Analiza tuturor fișierelor .env existente. Crearea unei matrici de mapare: Variabilă Veche -> Cale Nouă OpenBao. Exemplu: CP_IDT_AUTH_JWT_SECRET -> secret/prod/identity/auth:jwt_secret.

#### F0.5.7: Migrare Secrete Statice (Operațional)

Scop: Popularea seifului.
Acțiune: Crearea unui utilitar scripts/security/seed_secrets.sh.
Acest script va citi valorile dintr-o sursă sigură (ex: input interactiv sau un fișier temporar criptat/ignorat) și le va scrie în OpenBao folosind bao kv put.
Este vital ca acest script să nu conțină valorile secretelor hardcodate.

#### F0.5.8: Standard Criptografic (Conformitate)

Scop: Asigurarea calității secretelor.
Acțiune: Impunerea standardului de 256 biți de entropie pentru orice secret generat intern. Documentarea comenzilor standard (openssl rand -base64 32) pentru generarea manuală a noilor secrete.

### Faza 3: Dinamism și Protecție Avansată

#### F0.5.9: Strategie Encryption-at-Rest (Defense in Depth)

Scop: Protecția datelor PII în baza de date.
Acțiune: Implementarea pgcrypto.
Generarea unei chei de criptare master (256-bit).
Stocarea cheii în OpenBao (secret/prod/global/pgcrypto_key).
Configurarea aplicațiilor pentru a cere această cheie la pornire și a o folosi în query-uri SQL (pgp_sym_encrypt).

#### F0.5.10 - F0.5.12: Secrete Dinamice DB

Scop: Eliminarea parolelor statice de DB.
Acțiune:
Activarea engine-ului database în OpenBao.
Configurarea conexiunii "root" a OpenBao către PostgreSQL (cu un user admin dedicat).
Definirea rolurilor SQL (ex: numeriqo-role) care creează useri efemeri cu permisiuni limitate și TTL scurt (1 oră).

### Faza 4: Integrarea Aplicațiilor și CI/CD

#### F0.5.13: Ingineria Imaginii de Bază (Unified Runtime)

Scop: Crearea unei imagini Docker (ex: `geniussuite/node-with-bao:20`) care include binarul OpenBao Agent.
Acțiune: Crearea `shared/docker/node-openbao.Dockerfile` prin multi-stage build (copy from `openbao/agent`). Aceasta devine baza pentru toate aplicațiile.

#### F0.5.14: Implementare Sidecar / Process Supervisor (Pilot)

Scop: Conectarea aplicațiilor la OpenBao folosind imaginea unificată.
Acțiune: Actualizarea `numeriqo.app` pentru a folosi imaginea creată la F0.5.13.
Configurarea entrypoint-ului pentru a lansa agentul OpenBao, care ulterior pornește aplicația Node.js (proces copil).
Definirea template-urilor pentru injectarea variabilelor de mediu.

#### F0.5.15: Developer Experience & Training

Scop: Documente și tooling pentru noile fluxuri Process Supervisor.
Acțiune: Creează ghiduri în `docs/devx/OpenBao-Process-Supervisor.md`, actualizează `scripts/start-suite.sh` și oferă comenzi helper (`pnpm dev:openbao`) pentru a masca complexitatea locală.

#### F0.5.16 - F0.5.17: Templating

Scop: Traducerea structurilor JSON din OpenBao în variabile de mediu plate.
Acțiune: Crearea fișierelor .ctmpl (Consul Template) care mapează secretele din KV și Database engine către variabilele NUMQ_... așteptate de aplicație.

#### F0.5.18: Script Injecție (Dacă este necesar)

Scop: Plan de rezervă sau pre-procesare.
Acțiune: Dacă modul Process Supervisor nu este suficient pentru anumite scenarii complexe, se implementează scriptul inject.ts care rulează ca entrypoint, așteaptă randarea fișierului de secrete și apoi încarcă variabilele înainte de a porni aplicația.

#### F0.5.19 - F0.5.21: CI/CD OIDC

Scop: Securizarea pipeline-ului de release.
Acțiune:
Configurarea trust-ului OIDC între OpenBao și GitHub Actions.
Crearea rolurilor care permit pipeline-ului să citească doar secretele necesare build-ului (ex: NPM_TOKEN), condiționate de repo și branch.
Actualizarea workflow-ului release.yml pentru a folosi autentificarea JWT.

#### F0.5.22: Revocarea și Curățarea Secretelor Vechi (Cleanup)

Scop: Eliminarea datoriilor tehnice de securitate post-migrare.
Acțiune: Ștergerea secretelor statice din GitHub Secrets și rotirea tuturor credențialelor care au fost migrate în OpenBao (invalidarea celor vechi).

## 6. Concluzii

Implementarea planului F0.5 transformă fundamental postura de securitate a suitei GeniusERP. Trecerea de la configurații statice, vulnerabile la erori umane și scurgeri de date, la un sistem dinamic, guvernat de politici stricte și automatizare, este un pas esențial pentru o platformă enterprise.
Deși arhitectura Docker Compose prezintă provocări specifice (race conditions), soluția "Process Supervisor" oferită de OpenBao Agent este o rezolvare elegantă și robustă, care elimină complexitatea sincronizării containerelor. Integrarea pgcrypto oferă un strat vital de protecție a datelor sensibile, independent de capabilitățile infrastructurii de bază. Prin adoptarea OpenBao și OIDC, GeniusERP nu doar că rezolvă problemele curente, dar se poziționează pe o traiectorie de securitate modernă, scalabilă și "cloud-ready".

## 7. Anexa: Lista Completă de Task-uri (Format JSON)

```JSON
{
  "F0.5.1": {
    "denumire_task": "Analiza Strategie Configurare",
    "descriere_scurta_task": "Document de audit care demonstrează riscurile fișierelor .env mixte.",
    "descriere_lunga_si_detaliata_task": "Extinde documentul `Strategie Securitate F0.5` cu un capitol care corelează exemple reale (ex. `NUMQ_DB_PASS`) cu rapoartele ENV și cu regulile din `Strategii de Fișiere.env și Porturi.md`, pentru a fundamenta schimbarea arhitecturii.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/Plan",
      "/var/www/GeniusSuite/docs/security"
    ],
    "contextul_taskurilor_anterioare": "Continuă F0.4 (guvernanță și infrastructură) și folosește rapoartele ENV.",
    "contextul_general_al_aplicatiei": "Stabilește baza legală și tehnică pentru F0.5 înainte de a modifica compose-urile.",
    "contextualizarea_directoarelor_si_cailor": "Editează `Plan/Strategie Securitate F0.5_OpenBao_ENV.md` și menționează explicit `Plan/Strategii de Fișiere.env și Porturi.md`.",
    "restrictii_anti_halucinatie": "Folosește doar riscuri demonstrate (loguri CI, incidente reale), nu ipoteze nevalidate.",
    "restrictii_de_iesire_din_contex": "Nu modifica alte planuri decât prin citare; păstrează stilul JSON existent.",
    "validare": "Documentul include un capitol nou (Audit) cu legături către rapoartele ENV și exemple concrete.",
    "outcome": "Există o analiză acceptată care descrie vectorii de risc .env.",
    "componenta_de_CI_CD": "Serveste drept referință pentru controalele Pull Request (checklist securitate)."
  },
  "F0.5.2": {
    "denumire_task": "Politica Config vs. Secrete",
    "descriere_scurta_task": "Definirea regulilor hibride de guvernanță.",
    "descriere_lunga_si_detaliata_task": "Creează `docs/security/F0.5-Politica-Config-vs-Secrete.md` cu matrice de clasificare, aplicații practice și reguli de code-review inspirate din inventarul variabilelor.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/docs/security"
    ],
    "contextul_taskurilor_anterioare": "Depinde de concluziile F0.5.1.",
    "contextul_general_al_aplicatiei": "Asigură un standard comun pentru developers, DevSecOps și QA.",
    "contextualizarea_directoarelor_si_cailor": "Documentul trebuie referențiat din README-urile orchestratorilor și din `docs/ENV-IMPLEMENTATION-SUMMARY.md`.",
    "restrictii_anti_halucinatie": "Nu introduce categorii care nu există în proiect; folosește prefixele din `Strategii de Fișiere.env...`.",
    "restrictii_de_iesire_din_contex": "Nu muta actualele fișiere .env, doar documentează regulile.",
    "validare": "Politica este citată în șabloanele PR și acceptată de ownerii de domeniu.",
    "outcome": "Există reguli aprobate pentru separarea config/secrete.",
    "componenta_de_CI_CD": "Folosită de joburile lint pentru a respinge secrete noi în .env."
  },
  "F0.5.3": {
    "denumire_task": "Serviciu OpenBao în Root Compose",
    "descriere_scurta_task": "Adăugarea serviciului OpenBao în `compose.yml` cu volume și rețele corecte.",
    "descriere_lunga_si_detaliata_task": "Actualizează orchestratorul root pentru a include containerul `openbao/openbao`, definește volumul `gs_openbao_data` (external: true) și conectează serviciul strict la `net_backing_services` și `net_observability`, conform strategiei Docker.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite"
    ],
    "contextul_taskurilor_anterioare": "Necesită guvernanță definită (F0.5.1–F0.5.2).",
    "contextul_general_al_aplicatiei": "Creează serviciul central de secrete pentru toate aplicațiile suitei.",
    "contextualizarea_directoarelor_si_cailor": "Modifică `compose.yml` și secțiunea `volumes` pentru a adăuga `gs_openbao_data` definit la root.",
    "restrictii_anti_halucinatie": "Nu expune OpenBao pe `net_edge`; nu inventa porturi externe.",
    "restrictii_de_iesire_din_contex": "Nu șterge alte servicii; respectă schema existentă.",
    "validare": "`docker compose up openbao` pornește cu succes, iar `docker network inspect` arată doar rețelele aprobate.",
    "outcome": "OpenBao rulează în root stack cu volum persistent.",
    "componenta_de_CI_CD": "CI poate porni serviciul pentru teste de integrare."
  },
  "F0.5.4": {
    "denumire_task": "Bootstrap & Unseal Script",
    "descriere_scurta_task": "Automatizează inițializarea și unseal-ul OpenBao.",
    "descriere_lunga_si_detaliata_task": "Creează `scripts/security/openbao-init.sh` care detectează statusul, rulează `bao operator init`, salvează cheile într-un fișier ignorat (`.secrets/openbao.json`), execută unseal și verifică sănătatea endpoint-ului.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/scripts/security"
    ],
    "contextul_taskurilor_anterioare": "Necesită OpenBao definit (F0.5.3).",
    "contextul_general_al_aplicatiei": "Reduce fricțiunea pentru devs și CI, asigurând un bootstrap replicabil.",
    "contextualizarea_directoarelor_si_cailor": "Scriptul trebuie să fie apelat din `scripts/start-suite.sh` și documentat în README.",
    "restrictii_anti_halucinatie": "Nu persista cheile în Git; folosește doar căi gitignored.",
    "restrictii_de_iesire_din_contex": "Nu modifica politicile de permisiuni ale sistemului; scriptul trebuie să fie idempotent.",
    "validare": "Rularea scriptului pe un mediu curat generează cheile și raportează `initialized=true`.",
    "outcome": "Bootstrap-ul OpenBao devine un singur pas documentat.",
    "componenta_de_CI_CD": "Poate fi apelat în joburile CI înainte de teste care consumă secrete."
  },
  "F0.5.5": {
    "denumire_task": "Politici ACL și Namespace-uri",
    "descriere_scurta_task": "Definirea politicilor HCL pentru fiecare domeniu.",
    "descriere_lunga_si_detaliata_task": "Creează fișiere `scripts/security/policies/<component>.hcl` care aplică principiul least privilege pentru cp, apps și infrastructură, folosind namespace-urile planificate și mapând prefixele din `.env` la căi KV/DB.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/scripts/security/policies"
    ],
    "contextul_taskurilor_anterioare": "Necesită OpenBao operațional (F0.5.4).",
    "contextul_general_al_aplicatiei": "Asigură controlul granular cerut de Zero Trust.",
    "contextualizarea_directoarelor_si_cailor": "Politicile trebuie referite în documentul F0.5 și în scripturile de seed.",
    "restrictii_anti_halucinatie": "Nu crea politici pentru componente inexistente.",
    "restrictii_de_iesire_din_contex": "Nu acorda privilegii `sudo`/`root` generice; fiecare politică trebuie să fie scop-limitat.",
    "validare": "`bao policy write` reușește pentru fiecare fișier și `bao token capabilities` confirmă permisiunile corecte.",
    "outcome": "Politici versionate pentru toate domeniile aplicației.",
    "componenta_de_CI_CD": "CI poate genera token-uri cu capabilități limitate pentru joburi specifice."
  },
  "F0.5.6": {
    "denumire_task": "Inventariere Secrete",
    "descriere_scurta_task": "Catalogarea tuturor variabilelor .env și maparea lor către OpenBao.",
    "descriere_lunga_si_detaliata_task": "Produce `docs/security/F0.5-Secrets-Inventory-OpenBao.csv` (sau .md) cu coloane: componentă, variabila existentă, categorie (config/secret), cale KV/engine și status migrare.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/docs/security",
      "/var/www/GeniusSuite/*/.env"
    ],
    "contextul_taskurilor_anterioare": "Bazat pe politica F0.5.2.",
    "contextul_general_al_aplicatiei": "Previne omisiunile și dă trasabilitate.",
    "contextualizarea_directoarelor_si_cailor": "Inventarul trebuie referit de scripturile de seed și de QA.",
    "restrictii_anti_halucinatie": "Nu inventaria variabile inexistente; verifică fiecare fișier real.",
    "restrictii_de_iesire_din_contex": "Nu include valorile efective în document, doar numele și locațiile.",
    "validare": "Inventarul este revizuit de ownerii componentelor și semnat.",
    "outcome": "Lista completă a secretelor și a destinației lor în OpenBao.",
    "componenta_de_CI_CD": "Servește ca sursă pentru verificări automate ale configurațiilor."
  },
  "F0.5.7": {
    "denumire_task": "Migrare Secrete Statice",
    "descriere_scurta_task": "Script care înscrie secretele existente în OpenBao.",
    "descriere_lunga_si_detaliata_task": "Creează `scripts/security/seed_secrets.sh` (sau utilitar TypeScript) ce citește inventarul, solicită valorile actuale și execută `bao kv put` pentru fiecare cale, fără a scrie valorile pe disc.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/scripts/security"
    ],
    "contextul_taskurilor_anterioare": "Necesită politicile (F0.5.5) și inventarul (F0.5.6).",
    "contextul_general_al_aplicatiei": "Mută secret-zero din fișiere în seif.",
    "contextualizarea_directoarelor_si_cailor": "Scriptul trebuie să funcționeze pentru profile dev/staging/prod prin argumente.",
    "restrictii_anti_halucinatie": "Nu hardcoda valori; folosește input interactiv sau variabile de mediu temporare.",
    "restrictii_de_iesire_din_contex": "Nu comite fișiere temporare generate.",
    "validare": "`bao kv get` confirmă existența tuturor secretelor mapate.",
    "outcome": "Toate secretele statice sunt populate în OpenBao.",
    "componenta_de_CI_CD": "Permite joburilor CI să consume secrete via OIDC, fără GitHub Secrets persistente."
  },
  "F0.5.8": {
    "denumire_task": "Standard Criptografic Intern",
    "descriere_scurta_task": "Documentarea regulilor pentru generarea și rotația cheilor.",
    "descriere_lunga_si_detaliata_task": "Creează `docs/security/F0.5-Crypto-Standards-OpenBao.md` cu cerințe minime (≥256 biți entropie, algoritmi aprobați, proceduri rotate) și exemple de comenzi (`openssl`, `age`).",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/docs/security"
    ],
    "contextul_taskurilor_anterioare": "Necesită migrarea secretelor (F0.5.7) pentru a identifica lacunele.",
    "contextul_general_al_aplicatiei": "Asigură consistență și auditabilitate pentru toate cheile generate intern.",
    "contextualizarea_directoarelor_si_cailor": "Documentul trebuie legat din README-urile componentelor sensibile (identity, licensing).",
    "restrictii_anti_halucinatie": "Nu menționa algoritmi neacceptați (ex. MD5).",
    "restrictii_de_iesire_din_contex": "Păstrează formatul doc-urilor de securitate existente.",
    "validare": "Documentul este aprobat de responsabilul de securitate.",
    "outcome": "Standard criptografic intern publicat.",
    "componenta_de_CI_CD": "Folosit pentru validări automate (ex. lint ce verifică lungimea cheilor)."
  },
  "F0.5.9": {
    "denumire_task": "Implementare pgcrypto",
    "descriere_scurta_task": "Activează pgcrypto și criptează coloanele sensibile.",
    "descriere_lunga_si_detaliata_task": "Scrie migrații (Drizzle/SQL) pentru bazele critice (identity, numeriqo etc.) care adaugă `CREATE EXTENSION pgcrypto`, coloane criptate și funcții de utilitate; aplicațiile trebuie să ceară cheia din OpenBao.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/database/migrations",
      "/var/www/GeniusSuite/shared/common"
    ],
    "contextul_taskurilor_anterioare": "Necesită standardul criptografic și cheile (F0.5.7–F0.5.8).",
    "contextul_general_al_aplicatiei": "Aplică Defense in Depth pentru PII.",
    "contextualizarea_directoarelor_si_cailor": "Migrațiile trebuie să fie referite în `scripts/db` și în README-urile aplicațiilor.",
    "restrictii_anti_halucinatie": "Nu presupune TDE disponibil; documentează fallback-urile.",
    "restrictii_de_iesire_din_contex": "Nu rupe compatibilitatea cu seeds existente; folosește migrații backward-compatible.",
    "validare": "Testele unitare demonstră criptarea/decriptarea și scriptul de migrare rulează fără erori.",
    "outcome": "Coloanele sensibile sunt criptate la nivel de aplicație.",
    "componenta_de_CI_CD": "Testele CI trebuie să ruleze noile migrații și să se conecteze prin secrete dinamice."
  },
  "F0.5.10": {
    "denumire_task": "Configurare Engine Dinamic DB",
    "descriere_scurta_task": "Activează Database Secrets Engine în OpenBao.",
    "descriere_lunga_si_detaliata_task": "Scrie `scripts/security/openbao-enable-db-engine.sh` care configurează conexiunea administrativă către PostgreSQL (user dedicat), activează engine-ul `database/` și setează parametrizarea TTL.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/scripts/security",
      "/var/www/GeniusSuite/compose.yml"
    ],
    "contextul_taskurilor_anterioare": "Depinde de F0.5.3 și F0.5.7.",
    "contextul_general_al_aplicatiei": "Asigură generarea automată a credențialelor DB.",
    "contextualizarea_directoarelor_si_cailor": "Scriptul trebuie să folosească variabile din `.suite.general.env` pentru conectare.",
    "restrictii_anti_halucinatie": "Nu reutiliza contul `suite_admin`; creează un user separat conform `Strategie Docker`.",
    "restrictii_de_iesire_din_contex": "Nu lăsa engine-ul fără policy; asociază-l cu politicile scrise la F0.5.5.",
    "validare": "`bao secrets list` arată engine-ul activ, iar `bao write database/config/...` se finalizează.",
    "outcome": "Engine-ul DB este disponibil pentru toate aplicațiile.",
    "componenta_de_CI_CD": "CI poate genera credențiale efemere pentru testele e2e."
  },
  "F0.5.11": {
    "denumire_task": "Roluri Efemere per Aplicație",
    "descriere_scurta_task": "Definirea rolurilor SQL și a politicilor asociate.",
    "descriere_lunga_si_detaliata_task": "Creează scripturi SQL în `database/roles/` (ex. `numeriqo-role.sql`) care setează permisiuni limitate; configurează `bao write database/roles/<role>` pentru a lega SQL-ul de engine.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/database/roles",
      "/var/www/GeniusSuite/scripts/security"
    ],
    "contextul_taskurilor_anterioare": "Necesită engine activ (F0.5.10).",
    "contextul_general_al_aplicatiei": "Aplică principiul least privilege la nivel DB.",
    "contextualizarea_directoarelor_si_cailor": "Rolurile trebuie documentate în README-urile aplicațiilor și în inventar.",
    "restrictii_anti_halucinatie": "Nu acorda privilegii globale (DROP DATABASE) rolurilor aplicațiilor.",
    "restrictii_de_iesire_din_contex": "Folosește naming consistent (ex. `numeriqo_runtime`) pentru a evita coliziuni.",
    "validare": "`bao read database/creds/<role>` returnează user/secret și TTL corect.",
    "outcome": "Fiecare aplicație primește credențiale efemere limitate.",
    "componenta_de_CI_CD": "Joburile CI pot solicita credențiale temporare per componentă."
  },
  "F0.5.12": {
    "denumire_task": "Rotație Automată Credite DB",
    "descriere_scurta_task": "Watcher care reînnoiește și monitorizează lease-urile DB.",
    "descriere_lunga_si_detaliata_task": "Implementă `scripts/security/watchers/db-creds-renew.sh` (sau serviciu) care rulează periodic `bao lease renew`, trimite semnale către Process Supervisor și expune metrici (lifetime, expiring leases) către stack-ul de observabilitate.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/scripts/security/watchers",
      "/var/www/GeniusSuite/shared/observability"
    ],
    "contextul_taskurilor_anterioare": "Depinde de rolurile efemere (F0.5.11).",
    "contextul_general_al_aplicatiei": "Previne downtime cauzat de expirarea credențialelor.",
    "contextualizarea_directoarelor_si_cailor": "Watcher-ul trebuie integrat în `shared/observability` pentru metrici.",
    "restrictii_anti_halucinatie": "Nu stoca lease-id-uri pe disc; folosește storage securizat (tmpfs).",
    "restrictii_de_iesire_din_contex": "Nu crea cron-uri separate per aplicație; suportă listă configurabilă.",
    "validare": "Simularea expirării unui lease este detectată și reînnoită fără downtime.",
    "outcome": "Lease-urile DB sunt rotite automat și monitorizate.",
    "componenta_de_CI_CD": "CI poate testa scenarii de rotație în workflow-uri dedicate."
  },
  "F0.5.13": {
    "denumire_task": "Ingineria Imaginii de Bază (Unified Runtime)",
    "descriere_scurta_task": "Crearea imaginii Docker hibride Node.js + OpenBao Agent.",
    "descriere_lunga_si_detaliata_task": "Creează `shared/docker/node-openbao.Dockerfile` (sau similar) care pornește de la imaginea oficială Node.js și copiază binarul `bao` din `openbao/agent`. Această imagine va fi baza pentru toate aplicațiile care necesită Process Supervisor.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/shared/docker"
    ],
    "contextul_taskurilor_anterioare": "Depinde de decizia de arhitectură F0.5.1.",
    "contextul_general_al_aplicatiei": "Rezolvă problema tehnică a rulării agentului și aplicației în același container.",
    "contextualizarea_directoarelor_si_cailor": "Imaginea trebuie să fie build-uită și tag-uită local sau în registry-ul CI.",
    "restrictii_anti_halucinatie": "Nu folosi `apk add openbao` dacă nu există pachet; folosește `COPY --from`.",
    "restrictii_de_iesire_din_contex": "Păstrează versiunile de Node.js sincronizate cu restul proiectului.",
    "validare": "`docker run ... bao --version && node --version` returnează ambele versiuni corect.",
    "outcome": "Imagine de bază reutilizabilă disponibilă.",
    "componenta_de_CI_CD": "Pipeline de build pentru imaginea de bază."
  },
  "F0.5.14": {
    "denumire_task": "Process Supervisor Pilot (Numeriqo)",
    "descriere_scurta_task": "Integrează OpenBao Agent în `numeriqo.app` folosind imaginea unificată.",
    "descriere_lunga_si_detaliata_task": "Actualizează `numeriqo.app/Dockerfile` (sau compose) pentru a folosi imaginea creată la F0.5.13. Configurează blocul `exec` care lansează aplicația Node.js și definește montările necesare pentru șabloane.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/numeriqo.app/compose",
      "/var/www/GeniusSuite/shared/common"
    ],
    "contextul_taskurilor_anterioare": "Depinde de F0.5.13 și secrete populate (F0.5.7–F0.5.12).",
    "contextul_general_al_aplicatiei": "Demonstrează că aplicațiile pot rula fără secrete locale.",
    "contextualizarea_directoarelor_si_cailor": "Actualizează README-ul `numeriqo.app` cu pașii noi de pornire.",
    "restrictii_anti_halucinatie": "Nu păstra fallback `.env`; testul trebuie să folosească exclusiv secrete injectate.",
    "restrictii_de_iesire_din_contex": "Asigură-te că healthcheck-urile existente nu sunt eliminate.",
    "validare": "`docker compose up numeriqo` pornește cu secrete injectate și conectare reușită la DB cu credențiale efemere.",
    "outcome": "Pilot funcțional pentru Process Supervisor.",
    "componenta_de_CI_CD": "Workflow dedicat rulează `docker compose up numeriqo` cu agentul activ."
  },
  "F0.5.15": {
    "denumire_task": "Developer Experience & Training",
    "descriere_scurta_task": "Documente și tooling pentru noile fluxuri Process Supervisor.",
    "descriere_lunga_si_detaliata_task": "Creează ghiduri în `docs/devx/OpenBao-Process-Supervisor.md`, actualizează `scripts/start-suite.sh` și oferă comenzi helper (`pnpm dev:openbao`) pentru a masca complexitatea locală, inclusiv scenarii CLI/migrații.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/docs/devx",
      "/var/www/GeniusSuite/scripts"
    ],
    "contextul_taskurilor_anterioare": "Depinde de implementarea pilotului (F0.5.14).",
    "contextul_general_al_aplicatiei": "Protejează productivitatea descrisă în planul principal.",
    "contextualizarea_directoarelor_si_cailor": "Link către ghid din README-ul root și din `Plan/GeniusERP_Suite_Plan_v1.0.5.md` (Capitol F0).",
    "restrictii_anti_halucinatie": "Instrucțiunile trebuie testate pe un dev machine real.",
    "restrictii_de_iesire_din_contex": "Nu elimina fluxurile vechi până când noile tool-uri sunt validate de echipă.",
    "validare": "Cel puțin doi dezvoltatori folosesc ghidul și confirmă că pot porni aplicațiile fără `.env` locale.",
    "outcome": "DX clar pentru F0.5, reducând workaround-urile per-app.",
    "componenta_de_CI_CD": "README-ul CI menționează noile scripturi pentru rularea testelor locale."
  },
  "F0.5.16": {
    "denumire_task": "Templating Static",
    "descriere_scurta_task": "Șabloane Consul pentru variabile statice.",
    "descriere_lunga_si_detaliata_task": "Creează fișiere `.ctmpl` (ex. `numeriqo.app/env/openbao-static.ctmpl`) care mapază secrete KV la variabile NUMQ_* și sunt procesate de agent înainte de a porni aplicația.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/*/env",
      "/var/www/GeniusSuite/shared/observability/templates"
    ],
    "contextul_taskurilor_anterioare": "Se bazează pe pilotul sidecar (F0.5.14).",
    "contextul_general_al_aplicatiei": "Uniformizează modul în care secretele sunt expuse aplicațiilor.",
    "contextualizarea_directoarelor_si_cailor": "Template-urile trebuie referite din compose și testate cu `consul-template` CLI.",
    "restrictii_anti_halucinatie": "Nu miza pe fișiere temporare pe disc pentru secret final.",
    "restrictii_de_iesire_din_contex": "Respectă naming-ul variabilelor din Strategia .env.",
    "validare": "Rulează agentul în modul dry-run și verifică exportul variabilelor.",
    "outcome": "Șabloane statice disponibile pentru toate componentele pilotate.",
    "componenta_de_CI_CD": "Test static ce validează că toate placeholder-ele au secret disponibil."
  },
  "F0.5.17": {
    "denumire_task": "Templating Dinamic DB",
    "descriere_scurta_task": "Extinde șabloanele pentru credențiale dinamice și TTL.",
    "descriere_lunga_si_detaliata_task": "Update `.ctmpl` pentru a prelua output-ul `database/creds/<role>` și pentru a expune variabile suplimentare (lease_id, ttl) făcându-le disponibile Process Supervisor-ului și instrumentării.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/*/env"
    ],
    "contextul_taskurilor_anterioare": "Depinde de F0.5.16 și rolurile efemere (F0.5.11).",
    "contextul_general_al_aplicatiei": "Permite rotația fără restart complet.",
    "contextualizarea_directoarelor_si_cailor": "Șabloanele trebuie compatibile cu `consul-template`/OpenBao Agent.",
    "restrictii_anti_halucinatie": "Nu scrie lease info în loguri neprotejate.",
    "restrictii_de_iesire_din_contex": "Menține compatibilitatea cu `shared/observability` pentru metrici.",
    "validare": "Lease-ul se reînnoiește și variabilele actualizate sunt injectate fără re-build.",
    "outcome": "Șabloane dinamice complet funcționale.",
    "componenta_de_CI_CD": "Test e2e ce verifică rotația lease-urilor în pipeline."
  },
  "F0.5.18": {
    "denumire_task": "Script de Injecție Fallback",
    "descriere_scurta_task": "Entry-point auxiliar pentru scenarii complexe.",
    "descriere_lunga_si_detaliata_task": "Creează `scripts/security/inject.ts` (sau .js) care citește fișierele randate, validează completitudinea secretelor și pornește aplicații care nu pot fi controlate direct de agent (CLI, worker-e).",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/scripts/security",
      "/var/www/GeniusSuite/shared/common"
    ],
    "contextul_taskurilor_anterioare": "Depinde de templating (F0.5.16).",
    "contextul_general_al_aplicatiei": "Oferă fallback pentru servicii care nu suportă Process Supervisor complet.",
    "contextualizarea_directoarelor_si_cailor": "Scriptul trebuie inclus în imaginea base și documentat în `scripts/start-suite.sh`.",
    "restrictii_anti_halucinatie": "Nu păstra secrete în stdout/stderr; maschează output-ul.",
    "restrictii_de_iesire_din_contex": "Fallback-ul trebuie să fie opțional și să logheze când este folosit.",
    "validare": "Servicii CLI (ex. migrații) pot rula folosind scriptul fără `.env` locale.",
    "outcome": "Există o cale suportată pentru cazuri neacoperite de agent.",
    "componenta_de_CI_CD": "Folosit în joburile care rulează migrații DB."
  },
  "F0.5.19": {
    "denumire_task": "Configurare Trust OIDC",
    "descriere_scurta_task": "Activează autentificarea GitHub OIDC în OpenBao.",
    "descriere_lunga_si_detaliata_task": "Configurează OpenBao Auth Method pentru OIDC, adaugă providerul GitHub, importă JWKS, setează claim mappings (repo, branch) și documentează fluxul în `docs/security/F0.5-OIDC.md`.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/docs/security",
      "/var/www/GeniusSuite/scripts/security"
    ],
    "contextul_taskurilor_anterioare": "Necesită politici ACL (F0.5.5).",
    "contextul_general_al_aplicatiei": "Elimină secret-zero din GitHub Secrets.",
    "contextualizarea_directoarelor_si_cailor": "Documentul trebuie citat în `.github/` și în runbooks.",
    "restrictii_anti_halucinatie": "Folosește doar `token.actions.githubusercontent.com` ca issuers; nu accepta wildcard claims.",
    "restrictii_de_iesire_din_contex": "Nu lăsa metoda autentică activă fără politici asociate.",
    "validare": "Un workflow de test primește token OpenBao folosind OIDC și este limitat la politicile desemnate.",
    "outcome": "OpenBao acceptă OIDC și emite token-uri scurte pentru CI/CD.",
    "componenta_de_CI_CD": "Workflow-urile GitHub folosesc OIDC în loc de secrete statice."
  },
  "F0.5.20": {
    "denumire_task": "Roluri și Politici Pipeline",
    "descriere_scurta_task": "Script care leagă repo-urile/branch-urile de politici OIDC.",
    "descriere_lunga_si_detaliata_task": "Creează `scripts/security/setup_oidc_roles.sh` pentru a defini roluri (release, build, e2e) cu bound claims (ex. repo=`neacisu/GeniusERP_Suite`, ref=`refs/heads/dev`) și pentru a atașa politicile minime.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/scripts/security"
    ],
    "contextul_taskurilor_anterioare": "Depinde de F0.5.19.",
    "contextul_general_al_aplicatiei": "Aplica principiul „least privilege” în pipeline.",
    "contextualizarea_directoarelor_si_cailor": "Scriptul trebuie invocat după bootstrap-ul OpenBao în pipelines.",
    "restrictii_anti_halucinatie": "Nu crea roluri globale; fiecare rol trebuie mapat la un branch sau environ specific.",
    "restrictii_de_iesire_din_contex": "Nu salva token-uri rezultate; doar configurează politica.",
    "validare": "Workflow-urile reușesc să obțină token doar când claims corespund; restul sunt respinse.",
    "outcome": "Roluri pipeline cu politici bine definite.",
    "componenta_de_CI_CD": "Asigură că doar joburile autorizate citesc secretele necesare."
  },
  "F0.5.21": {
    "denumire_task": "Actualizare Workflow Release",
    "descriere_scurta_task": "Modifică `.github/workflows/release.yml` pentru a consuma secrete prin OIDC.",
    "descriere_lunga_si_detaliata_task": "Actualizează workflow-ul pentru a folosi `hashicorp/vault-action` (compatibil OpenBao), elimină secretele statice, injectează secretele necesare (NPM_TOKEN, Docker creds) și adaugă verificări pentru lease TTL.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/.github/workflows"
    ],
    "contextul_taskurilor_anterioare": "Depinde de F0.5.19–F0.5.20.",
    "contextul_general_al_aplicatiei": "Finalizează tranziția CI/CD către OpenBao.",
    "contextualizarea_directoarelor_si_cailor": "README-ul de release trebuie actualizat cu noile cerințe.",
    "restrictii_anti_halucinatie": "Nu păstra fallback secrete în GitHub; altfel compromite obiectivul.",
    "restrictii_de_iesire_din_contex": "Păstrează gating-ul existent (tests, lint).",
    "validare": "Workflow-ul rulează cap-coadă folosind doar OIDC și secrete efemere.",
    "outcome": "Release pipeline securizat fără secrete persistente.",
    "componenta_de_CI_CD": "Workflow-ul release este acum dependent de OpenBao pentru secrete."
  },
  "F0.5.22": {
    "denumire_task": "Revocarea și Curățarea Secretelor Vechi (Cleanup)",
    "descriere_scurta_task": "Ștergerea secretelor statice și rotirea credențialelor migrate.",
    "descriere_lunga_si_detaliata_task": "După migrarea completă la OIDC și OpenBao, acest task presupune ștergerea secretelor statice din GitHub Secrets și rotirea efectivă a tuturor parolelor/cheilor care au fost migrate în Vault (pentru a invalida vechile valori potențial compromise).",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/.github/workflows",
      "/var/www/GeniusSuite/scripts/security"
    ],
    "contextul_taskurilor_anterioare": "Depinde de finalizarea F0.5.21.",
    "contextul_general_al_aplicatiei": "Asigură că nu rămân 'uși deschise' uitate.",
    "contextualizarea_directoarelor_si_cailor": "Documentează acțiunea în `docs/security/F0.5-Cleanup.md`.",
    "restrictii_anti_halucinatie": "Nu șterge secretele înainte de a valida că pipeline-ul OIDC funcționează.",
    "restrictii_de_iesire_din_contex": "Asigură-te că rotirea nu blochează serviciile în producție (zero downtime).",
    "validare": "GitHub Secrets este gol (cu excepția celor non-migrabile) și credențialele vechi nu mai sunt valide.",
    "outcome": "Mediu curat și complet securizat.",
    "componenta_de_CI_CD": "Manual trigger sau script one-off."
  },
  "F0.5.23": {
    "denumire_task": "Backup & Disaster Recovery OpenBao",
    "descriere_scurta_task": "Integrare backup automat pentru volumul `gs_openbao_data`.",
    "descriere_lunga_si_detaliata_task": "Aplică prevederile din `Strategie Docker` (pilonul backup) pentru OpenBao: definește jobul sidecar de backup, politica de retenție, restore playbook și integrarea cu `scripts/compose/postgres-backup`.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/compose.yml",
      "/var/www/GeniusSuite/scripts/compose"
    ],
    "contextul_taskurilor_anterioare": "Depinde de F0.5.3 (serviciul există).",
    "contextul_general_al_aplicatiei": "Previne single point of failure pentru seiful de secrete.",
    "contextualizarea_directoarelor_si_cailor": "Adaugă volumul în secțiunea `volumes` și un container `openbao-backup` sau job Cron, documentat în `docs/ops`.",
    "restrictii_anti_halucinatie": "Nu copia datele în locații necriptate; folosește același mecanism de backup ca pentru PostgreSQL.",
    "restrictii_de_iesire_din_contex": "Backup-ul trebuie să fie offline-friendly și testat periodic.",
    "validare": "Rulează un exercițiu de restore într-un mediu izolat și verifică `bao status` după restaurare.",
    "outcome": "Plan complet de backup/restore pentru OpenBao.",
    "componenta_de_CI_CD": "CI poate rula testul de restore o dată pe săptămână (job programat)."
  },
  "F0.5.24": {
    "denumire_task": "Observabilitate & Alerte OpenBao",
    "descriere_scurta_task": "Dashboard-uri și alerte pentru sănătatea OpenBao și lease-uri.",
    "descriere_lunga_si_detaliata_task": "Extinde `shared/observability` pentru a colecta metrice (lease count, renew errors, seal status), configurează dashboards Grafana și alerte Prometheus bazate pe obiectivele din ENV report.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/shared/observability",
      "/var/www/GeniusSuite/docs/observability"
    ],
    "contextul_taskurilor_anterioare": "Depinde de watchers (F0.5.12) și OIDC (F0.5.19).",
    "contextul_general_al_aplicatiei": "Asigură vizibilitate asupra serviciului critic.",
    "contextualizarea_directoarelor_si_cailor": "Actualizează dashboard-urile din `shared/observability/grafana` și documentația din `docs/observability`.",
    "restrictii_anti_halucinatie": "Folosește doar metrice reale (OpenBao telemetry, watcher logs).",
    "restrictii_de_iesire_din_contex": "Nu emite alerte care expun secrete (log scrubbing obligatoriu).",
    "validare": "Alertă `OpenBaoLeaseExpiry` se declanșează într-un test controlat, iar dashboard-ul arată starea actuală.",
    "outcome": "Observabilitate completă pentru F0.5.",
    "componenta_de_CI_CD": "Joburi programate verifică sănătatea și raportează statusul în pipeline."
  },
  "F0.5.25": {
    "denumire_task": "Testare Integrare & Chaos pentru F0.5",
    "descriere_scurta_task": "Suite de teste care validează noile mecanisme (Process Supervisor, OIDC, backup).",
    "descriere_lunga_si_detaliata_task": "Adaugă scenarii în `__tests__/workflows` sau creează un workflow GitHub (`ci-f05-validation.yml`) care pornește stack-ul, verifică injecția secretelor, forțează expirarea lease-urilor, simulează `openbao down` și validează reacțiile aplicațiilor.",
    "directorul_directoarele": [
      "/var/www/GeniusSuite/__tests__/workflows",
      "/var/www/GeniusSuite/.github/workflows"
    ],
    "contextul_taskurilor_anterioare": "Depinde de întregul set F0.5, inclusiv taskurile noi.",
    "contextul_general_al_aplicatiei": "Asigură că schimbările de securitate nu introduc regresii.",
    "contextualizarea_directoarelor_si_cailor": "Testele trebuie să fie documentate în `docs/security/F0.5-Validation.md`.",
    "restrictii_anti_halucinatie": "Simulările trebuie să folosească comenzi reale (docker, bao), nu mock-uri.",
    "restrictii_de_iesire_din_contex": "Nu lăsa workflow-ul să ruleze necontrolat; marchează-l ca `manual` sau `nightly`.",
    "validare": "Workflow-ul rulează și raportează explicit starea fiecărui scenariu (pass/fail).",
    "outcome": "Există acoperire automată pentru principalele riscuri F0.5.",
    "componenta_de_CI_CD": "Devine parte a `CI Validation` înainte de promovarea în fazele superioare."
  }
}
```

### Analiză critică a impactului fazei F0.5

Strategia F0.5 schimbă centrul de greutate al securității dinspre fișiere distribuite către controale centralizate, însă ridică pragul operațional. Introducerea OpenBao ca serviciu critic suplimentar în `compose.yml` amplifică dependența de infrastructura din zona Backing Services: orice indisponibilitate a clusterului de secrete blochează Bootstrap-ul tuturor aplicațiilor, iar rapoartele din `docs/ENV-FINAL-VALIDATION-REPORT.md` arată deja sensibilitatea la outage-uri Postgres/Kafka. Este obligatorie definirea unor playbook-uri de recovery și a unei redundanțe minime (ex: backup automat al `gs_openbao_data`) pentru a preveni single point of failure.

Implementarea Process Supervisor pe toate containerele API produce un impact direct asupra experienței developerilor descrisă în `Plan/GeniusERP_Suite_Plan_v1.0.5.md`: ciclurile de `docker compose up` devin dependente de bootstrap-ul agentului, introducând latență suplimentară și complexitate în debugging. Fără tooling clar (log piping, healthchecks integrate), există risc de regresie în productivitate și de creștere a timpului mediu de remediere (MTTR). Faza F0.5.13 trebuie acompaniată de documentație și exemple clare per app, altfel există probabilitatea apariției workaround-urilor locale care diluează controlul centralizat al secretelor.

Migrarea către secrete dinamice și pgcrypto aliniază suitele la principiile "Zero Trust" documentate în `Plan/Strategii de Fișiere.env și Porturi.md`, dar introduce noi obligații de observabilitate. Lease-urile efemere trebuie urmărite prin stiva din `docs/observability/`, altfel rotațiile automate pot provoca întreruperi silențioase. În plus, integrarea OIDC pentru CI/CD reduce "secret zero" descris în rapoartele ENV, însă mută responsabilitatea către guvernanța politicilor GitHub (branch protection, restricții asupra workflow-urilor third-party). Lipsa unei revizuiri periodice a politicilor OIDC riscă să recreeze aceeași problemă de supra-permisivități, doar că la nivel de claims. În concluzie, F0.5 aduce un salt major în postura de securitate, dar necesită investiții continue în operare, training și observabilitate pentru a evita înlocuirea riscurilor vechi cu tehnical debt și procese fragile.
