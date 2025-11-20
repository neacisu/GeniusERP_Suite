
# Strategie securitate F0.5: Arhitectura de Securitate, Guvernanța Configurațiilor și Managementul Secretelor pentru Suita GeniusERP

## 1. Sumar Executiv

Prezentul raport constituie documentul de referință pentru inițiativa strategică "F0.5" din cadrul proiectului GeniusERP. Obiectivul fundamental al acestei cercetări este validarea, critica constructivă și rafinarea planului de tranziție de la o arhitectură de configurare statică, bazată pe fișiere .env distribuite, către o arhitectură dinamică, centralizată și securizată, guvernată de OpenBao. Această tranziție nu este doar o actualizare tehnologică, ci o schimbare de paradigmă necesară pentru a alinia suita GeniusERP la standardele moderne de "Defense in Depth" și "Zero Trust".
Analiza aprofundată a stării curente confirmă că, deși strategia existentă de nomenclatură a fișierelor .env oferă o guvernanță excelentă și previne coliziunile de variabile într-un mediu monorepo complex, ea introduce vulnerabilități critice de securitate. Practica de a amesteca configurațiile non-sensibile (ex: porturi, domenii) cu secretele de mare valoare (ex: parole de baze de date, chei API) într-un singur artefact (fișierul .env) creează un vector de atac semnificativ. Riscul de scurgere a datelor prin sistemele de control al versiunilor (Git) este inacceptabil de ridicat, iar rotația credențialelor devine un proces manual, predispus la erori umane și fricțiune operațională.
Soluția propusă, care implică adoptarea OpenBao ca manager de secrete, implementarea modelului Sidecar pentru injecția secretelor la runtime și utilizarea autentificării OIDC (OpenID Connect) pentru pipeline-urile CI/CD, este validată ca fiind robustă și necesară. OpenBao, fiind un fork open-source al HashiCorp Vault gestionat sub egida Linux Foundation, asigură libertatea de licențiere pe termen lung, menținând în același timp compatibilitatea tehnică cu ecosistemul vast de unelte Vault.
Totuși, raportul identifică provocări tehnice majore care nu au fost detaliate suficient în planul inițial, în special problema "race condition" în orchestratorul Docker Compose, unde containerele aplicației pot porni înainte ca agentul sidecar să livreze secretele. De asemenea, se clarifică distincția critică între criptarea transparentă a datelor (TDE) la nivel de disc și criptarea la nivel de coloană (pgcrypto), recomandând o abordare stratificată.
În final, raportul detaliază o strategie hibridă clară: configurațiile non-sensibile rămân în Git pentru trasabilitate, în timp ce secretele sunt gestionate exclusiv de OpenBao și injectate efemer. Se propune o arhitectură de tip "Process Supervisor" pentru a rezolva limitările Docker Compose și se definește un set secvențial de task-uri (F0.5.x) pentru execuție.

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

Standardizarea numelor variabilelor este un succes arhitectural care trebuie păstrat în era OpenBao. Convenția '<PREFIX>_<CATEGORIE>_<NUME>' (de exemplu, CP_IDT_AUTH_JWT_SECRET sau NUMQ_DB_PASS) previne coliziunile în spațiul global de variabile de mediu. Într-un sistem distribuit unde zeci de containere pot partaja rețele sau volume, un nume generic precum DB_PASSWORD ar fi dezastruos, ducând la situații în care aplicația archify s-ar conecta accidental la baza de date a aplicației numeriqo. Utilizarea prefixelor specifice componentei (ex: NUMQ_ pentru Numeriqo, CP_IDT_ pentru Identity Control Plane) asigură claritate și izolare logică.

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

    - Containerul pornește, lansând Agentul OpenBao.
    - Agentul se autentifică și descarcă secretele.
    - Doar după ce secretele sunt pregătite, Agentul lansează procesul copil (node index.js).
    - Secretele sunt injectate direct în variabilele de mediu ale procesului copil, fără a mai fi nevoie de scrierea lor pe disc într-un volum partajat (ceea ce este mai sigur).
    - Agentul monitorizează ciclul de viață al aplicației și poate trimite semnale (ex: SIGTERM) pentru restartarea acesteia dacă secretele se schimbă (rotație).

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

#### F0.5.13: Implementare Sidecar / Process Supervisor

Scop: Conectarea aplicațiilor la OpenBao fără modificarea codului sursă ("OpenBao-unaware").
Acțiune: Refactorizarea docker-compose.yml pentru aplicații (ex: numeriqo.app).
Înlocuirea imaginii serviciului cu imaginea openbao-agent.
Configurarea agentului pentru a lansa aplicația Node.js ca proces copil.
Definirea template-urilor pentru injectarea variabilelor de mediu.

#### F0.5.14 - F0.5.15: Templating

Scop: Traducerea structurilor JSON din OpenBao în variabile de mediu plate.
Acțiune: Crearea fișierelor .ctmpl (Consul Template) care mapează secretele din KV și Database engine către variabilele NUMQ_... așteptate de aplicație.

#### F0.5.16: Script Injecție (Dacă este necesar)

Scop: Plan de rezervă sau pre-procesare.
Acțiune: Dacă modul Process Supervisor nu este suficient pentru anumite scenarii complexe, se implementează scriptul inject.ts care rulează ca entrypoint, așteaptă randarea fișierului de secrete și apoi încarcă variabilele înainte de a porni aplicația.

#### F0.5.17 - F0.5.19: CI/CD OIDC

Scop: Securizarea pipeline-ului de release.
Acțiune:
Configurarea trust-ului OIDC între OpenBao și GitHub Actions.
Crearea rolurilor care permit pipeline-ului să citească doar secretele necesare build-ului (ex: NPM_TOKEN), condiționate de repo și branch.
Actualizarea workflow-ului release.yml pentru a folosi autentificarea JWT.

## 6. Concluzii

Implementarea planului F0.5 transformă fundamental postura de securitate a suitei GeniusERP. Trecerea de la configurații statice, vulnerabile la erori umane și scurgeri de date, la un sistem dinamic, guvernat de politici stricte și automatizare, este un pas esențial pentru o platformă enterprise.
Deși arhitectura Docker Compose prezintă provocări specifice (race conditions), soluția "Process Supervisor" oferită de OpenBao Agent este o rezolvare elegantă și robustă, care elimină complexitatea sincronizării containerelor. Integrarea pgcrypto oferă un strat vital de protecție a datelor sensibile, independent de capabilitățile infrastructurii de bază. Prin adoptarea OpenBao și OIDC, GeniusERP nu doar că rezolvă problemele curente, dar se poziționează pe o traiectorie de securitate modernă, scalabilă și "cloud-ready".

## 7. Anexa: Lista Completă de Task-uri (Format JSON)

```JSON
{
  "phase": "F0.5",
  "title": "Securitate Zero-Trust & Managementul Secretelor (OpenBao)",
  "tasks": [
    {
      "id": "F0.5.1",
      "category": "Documentation",
      "title": "Analiza Strategie Configurare",
      "description": "Redactarea `docs/security/F0.5-Analiza-Strategie-Config.md`, corelând concluziile cu `Plan/Strategii de Fișiere.env și Porturi.md` și cu rapoartele ENV pentru a demonstra riscurile actualei strategii .env.",
      "deliverable": "docs/security/F0.5-Analiza-Strategie-Config.md",
      "priority": "high",
      "dependencies": []
    },
    {
      "id": "F0.5.2",
      "category": "Governance",
      "title": "Politica Config vs. Secrete",
      "description": "Definirea politicii hibride în `docs/security/F0.5-Politica-Config-vs-Secrete.md`, inclusiv reguli de code-review și matrice de clasificare inspirată din `docs/ENV-IMPLEMENTATION-SUMMARY.md`.",
      "deliverable": "docs/security/F0.5-Politica-Config-vs-Secrete.md",
      "priority": "high",
      "dependencies": ["F0.5.1"]
    },
    {
      "id": "F0.5.3",
      "category": "Infrastructure",
      "title": "Serviciu OpenBao în Root Compose",
      "description": "Actualizarea `compose.yml` rădăcină pentru a introduce serviciul `openbao` cu volume dedicate, capabilitatea IPC_LOCK și limitarea strictă la rețelele net_backing_services/net_observability.",
      "deliverable": "compose.yml",
      "priority": "critical",
      "dependencies": ["F0.5.1", "F0.5.2"]
    },
    {
      "id": "F0.5.4",
      "category": "Automation",
      "title": "Bootstrap & Unseal Script",
      "description": "Crearea `scripts/security/openbao-init.sh` care inițializează, unseal-uieste și validează statusul OpenBao conform ghidurilor din `docs/ENV-AUDIT-REPORT.md`.",
      "deliverable": "scripts/security/openbao-init.sh",
      "priority": "high",
      "dependencies": ["F0.5.3"]
    },
    {
      "id": "F0.5.5",
      "category": "Security",
      "title": "Politici ACL și Namespace-uri",
      "description": "Definirea politicilor HCL în `scripts/security/policies/*.hcl` pentru fiecare domeniu (cp, numeriqo, archify etc.), reflectând topologia Zero-Trust documentată în `Plan/Strategie Securitate F0.5`.",
      "deliverable": "scripts/security/policies/*.hcl",
      "priority": "high",
      "dependencies": ["F0.5.3", "F0.5.4"]
    },
    {
      "id": "F0.5.6",
      "category": "Audit",
      "title": "Inventariere Secrete",
      "description": "Inventarierea tuturor variabilelor din `.env`-urile din monorepo și maparea lor la căi OpenBao într-un registru versionat `docs/security/F0.5-Secrets-Inventory.csv`.",
      "deliverable": "docs/security/F0.5-Secrets-Inventory.csv",
      "priority": "high",
      "dependencies": ["F0.5.2"]
    },
    {
      "id": "F0.5.7",
      "category": "Operations",
      "title": "Migrare Secrete Statice",
      "description": "Implementarea utilitarului `scripts/security/seed_secrets.sh` care preia valorile din surse sigure și le înscrie în OpenBao `kv/` fără a persista datele pe disc.",
      "deliverable": "scripts/security/seed_secrets.sh",
      "priority": "critical",
      "dependencies": ["F0.5.5", "F0.5.6"]
    },
    {
      "id": "F0.5.8",
      "category": "Compliance",
      "title": "Standard Criptografic Intern",
      "description": "Documentarea ghidului `docs/security/F0.5-Crypto-Standards.md` (entropie minimă, algoritmi aprobați, proceduri de rotație) aliniat cu cerințele din `Plan/Strategie Securitate F0.5` și rapoartele ENV.",
      "deliverable": "docs/security/F0.5-Crypto-Standards.md",
      "priority": "medium",
      "dependencies": ["F0.5.5"]
    },
    {
      "id": "F0.5.9",
      "category": "Database",
      "title": "Implementare pgcrypto",
      "description": "Crearea unui set de migrații (ex: `database/migrations/2025Q1_pgcrypto.sql`) care activează extensia `pgcrypto`, adaugă coloane criptate și documentează consumul cheii din OpenBao.",
      "deliverable": "database/migrations/2025Q1_pgcrypto.sql",
      "priority": "high",
      "dependencies": ["F0.5.7", "F0.5.8"]
    },
    {
      "id": "F0.5.10",
      "category": "Database",
      "title": "Configurare Engine Dinamic DB",
      "description": "Automatizarea activării OpenBao Database Secrets Engine (script `scripts/security/openbao-enable-db-engine.sh`) și definirea conexiunii privilegiate către PostgreSQL global.",
      "deliverable": "scripts/security/openbao-enable-db-engine.sh",
      "priority": "high",
      "dependencies": ["F0.5.3", "F0.5.7"]
    },
    {
      "id": "F0.5.11",
      "category": "Database",
      "title": "Roluri Efemere per Aplicație",
      "description": "Crearea scripturilor SQL (ex: `database/roles/numeriqo-role.sql`) și a politicilor OpenBao aferente pentru emiterea de useri efemeri cu TTL scurt per aplicație.",
      "deliverable": "database/roles/*.sql",
      "priority": "high",
      "dependencies": ["F0.5.10"]
    },
    {
      "id": "F0.5.12",
      "category": "Automation",
      "title": "Rotație Automată Credite DB",
      "description": "Implementarea watcher-elor/cron-urilor (ex: `scripts/security/watchers/db-creds-renew.sh`) care orchestrează reînnoirea token-urilor și semnalează aplicațiile prin Process Supervisor.",
      "deliverable": "scripts/security/watchers/db-creds-renew.sh",
      "priority": "medium",
      "dependencies": ["F0.5.11"]
    },
    {
      "id": "F0.5.13",
      "category": "Integration",
      "title": "Process Supervisor Sidecar",
      "description": "Refactorizarea compoziției (pilot pe `numeriqo.app/compose/docker-compose.yml`) pentru a folosi imaginea `openbao/agent` ca entrypoint ce lansează aplicația Node.js și injectează secretele în memorie.",
      "deliverable": "numeriqo.app/compose/docker-compose.yml",
      "priority": "critical",
      "dependencies": ["F0.5.7", "F0.5.10", "F0.5.12"]
    },
    {
      "id": "F0.5.14",
      "category": "Integration",
      "title": "Templating Static",
      "description": "Crearea template-urilor Consul (`[app]/env/openbao.template.ctmpl`) care mapază KV-urile statice la variabilele de mediu prefixate.",
      "deliverable": "[app]/env/openbao.template.ctmpl",
      "priority": "high",
      "dependencies": ["F0.5.13"]
    },
    {
      "id": "F0.5.15",
      "category": "Integration",
      "title": "Templating Dinamic DB",
      "description": "Extinderea template-urilor pentru a include credențiale generate dinamic și pentru a expune TTL/lease id către aplicații pentru observabilitate.",
      "deliverable": "[app]/env/openbao.template.ctmpl",
      "priority": "high",
      "dependencies": ["F0.5.14", "F0.5.11"]
    },
    {
      "id": "F0.5.16",
      "category": "Integration",
      "title": "Script de Injecție Fallback",
      "description": "Implementarea `scripts/security/inject.ts` care poate fi folosit ca entrypoint auxiliar în aplicațiile care necesită validări suplimentare înainte de boot.",
      "deliverable": "scripts/security/inject.ts",
      "priority": "medium",
      "dependencies": ["F0.5.14"]
    },
    {
      "id": "F0.5.17",
      "category": "CI/CD",
      "title": "Configurare Trust OIDC",
      "description": "Configurarea OpenBao pentru a accepta JWT-uri GitHub (setare provider, chei publice, claim mapping) și documentarea fluxului în `docs/security/F0.5-OIDC.md`.",
      "deliverable": "OpenBao Auth Configuration",
      "priority": "high",
      "dependencies": ["F0.5.3", "F0.5.5"]
    },
    {
      "id": "F0.5.18",
      "category": "CI/CD",
      "title": "Roluri și Politici Pipeline",
      "description": "Script `scripts/security/setup_oidc_roles.sh` care mapează repo-urile/pipeline-urile la politicile minime necesare (NPM_TOKEN, docker credentials), folosind bound-claims pe branch-uri.",
      "deliverable": "scripts/security/setup_oidc_roles.sh",
      "priority": "high",
      "dependencies": ["F0.5.17"]
    },
    {
      "id": "F0.5.19",
      "category": "CI/CD",
      "title": "Actualizare Workflow Release",
      "description": "Adaptarea `.github/workflows/release.yml` pentru a consuma secrete prin `hashicorp/vault-action` (compatibil OpenBao) și pentru a elimina secretele persistente din GitHub Secrets.",
      "deliverable": ".github/workflows/release.yml",
      "priority": "high",
      "dependencies": ["F0.5.17", "F0.5.18"]
    }
  ]
}
```

### Analiză critică a impactului fazei F0.5

Strategia F0.5 schimbă centrul de greutate al securității dinspre fișiere distribuite către controale centralizate, însă ridică pragul operațional. Introducerea OpenBao ca serviciu critic suplimentar în `compose.yml` amplifică dependența de infrastructura din zona Backing Services: orice indisponibilitate a clusterului de secrete blochează Bootstrap-ul tuturor aplicațiilor, iar rapoartele din `docs/ENV-FINAL-VALIDATION-REPORT.md` arată deja sensibilitatea la outage-uri Postgres/Kafka. Este obligatorie definirea unor playbook-uri de recovery și a unei redundanțe minime (ex: backup automat al `gs_openbao_data`) pentru a preveni single point of failure.

Implementarea Process Supervisor pe toate containerele API produce un impact direct asupra experienței developerilor descrisă în `Plan/GeniusERP_Suite_Plan_v1.0.5.md`: ciclurile de `docker compose up` devin dependente de bootstrap-ul agentului, introducând latență suplimentară și complexitate în debugging. Fără tooling clar (log piping, healthchecks integrate), există risc de regresie în productivitate și de creștere a timpului mediu de remediere (MTTR). Faza F0.5.13 trebuie acompaniată de documentație și exemple clare per app, altfel există probabilitatea apariției workaround-urilor locale care diluează controlul centralizat al secretelor.

Migrarea către secrete dinamice și pgcrypto aliniază suitele la principiile "Zero Trust" documentate în `Plan/Strategii de Fișiere.env și Porturi.md`, dar introduce noi obligații de observabilitate. Lease-urile efemere trebuie urmărite prin stiva din `docs/observability/`, altfel rotațiile automate pot provoca întreruperi silențioase. În plus, integrarea OIDC pentru CI/CD reduce "secret zero" descris în rapoartele ENV, însă mută responsabilitatea către guvernanța politicilor GitHub (branch protection, restricții asupra workflow-urilor third-party). Lipsa unei revizuiri periodice a politicilor OIDC riscă să recreeze aceeași problemă de supra-permisivități, doar că la nivel de claims. În concluzie, F0.5 aduce un salt major în postura de securitate, dar necesită investiții continue în operare, training și observabilitate pentru a evita înlocuirea riscurilor vechi cu tehnical debt și procese fragile.
