# **Strategie de Implementare a Infrastructurii Docker pentru Suita GeniusERP**

**CĂTRE:** Conducerea Tehnică, Proiectul GeniusSuite **DE LA:** Expert Principal în Arhitectură DevOps și Infrastructură Cloud **DATA:** 24 Mai 2024 **CLASIFICARE:** Raport Strategic de Implementare (Confidențial)

## **1.0 Sinopsis Executiv**

Acest raport detaliază strategia tehnică prescriptivă pentru orchestrarea Docker a suitei GeniusERP, răspunzând cerințelor de stocare persistentă, rețelistică, siguranța datelor, backup și mentenanță automată. Analiza se bazează pe documentele de planificare arhitecturală furnizate (GeniusERP\_Suite\_Plan\_v1.0.5 și Strategii de Fișiere.env și Porturi).  
Arhitectura software a GeniusSuite, bazată pe un "model hibrid" de orchestrare Docker Compose (fișiere compose.yml per aplicație și un compose.yml orchestrator la rădăcină), introduce provocări unice pentru gestionarea serviciilor stateful. O strategie eronată poate duce la pierderi catastrofale de date în timpul operațiunilor de rutină, cum ar fi reconstrucția containerelor.  
Strategia propusă abordează aceste riscuri prin cinci piloni principali:

1. **Cartografierea Exhaustivă a Volumelor:** Identificarea și definirea fiecărui volum persistent necesar pentru serviciile stateful (PostgreSQL, Kafka, Temporal, Traefik, Observability etc.).  
2. **Protecția Datelor PostgreSQL:** O strategie de decuplare a ciclului de viață al datelor de cel al containerelor, folosind volume external: true pentru a preveni ștergerea accidentală la rebuild.  
3. **Topologie de Rețea Zero-Trust:** Implementarea formală a modelului de rețea cu patru zone (Edge, API, Backing Services, Observability) pentru a impune o segmentare strictă a traficului.  
4. **Backup Automatizat și Retenție:** Implementarea unui container "sidecar" dedicat pentru backup-uri zilnice pg\_dump și o politică de retenție de 7 zile, conform specificațiilor.  
5. **Igienă și Mentenanță Automată:** O strategie de curățare (pruning) în trei etape pentru cache-ul de build, volumele reziduale și imaginile Docker nefolosite, integrată în CI și operațiunile host-ului.

Acest document constituie planul de implementare (blueprint) pentru infrastructura de bază a suitei.

## **2.0 Partea 1: Cartografierea Exhaustivă a Volumelor Persistente (Stateful Services)**

### **2.1 Analiza Serviciilor "Stateful" în Arhitectura Hibridă GeniusSuite**

Arhitectura "hibridă" a suitei GeniusERP utilizează fișiere Docker Compose la nivel de aplicație pentru izolare și un fișier compose.yml orchestrator la rădăcină pentru serviciile partajate. Această arhitectură dictează strategia de gestionare a volumelor: volumele pentru serviciile partajate (infrastructură) trebuie gestionate de orchestratorul root, în timp ce volumele specifice aplicațiilor (stocare de fișiere) pot fi gestionate de compose-ul aplicației.  
O analiză aprofundată a stack-ului tehnologic relevă un număr semnificativ de servicii stateful care necesită stocare persistentă dincolo de PostgreSQL:

* **Baze de Date:** PostgreSQL 18  
* **Broker de Mesaje:** Apache Kafka 4.1.0  
* **Orchestrare BPM:** Temporal TS SDK 1.13.1  
* **Autentificare:** SuperTokens 11.2.0 LTS  
* **Graph DB:** Neo4j (pentru vettify.app)  
* **Observabilitate:** Prometheus, Loki, Tempo, Grafana  
* **Edge Proxy:** Traefik (pentru certificate ACME)  
* **Stocare Fișiere:** Stocare locală/MinIO (pentru archify.app)

Cercetarea confirmă că toate aceste servicii vor eșua sau vor pierde date critice dacă volumele persistente nu sunt alocate corect.  
Strategia adoptată va utiliza exclusiv "volume numite" (named volumes) gestionate de Docker, în detrimentul "bind mounts". Volumele numite sunt gestionate de motorul Docker, au un ciclu de viață independent și evită problemele complexe de permisiuni UID/GID ale fișierelor de pe host, asigurând portabilitatea mediului.  
Volumele sunt clasificate în (A) Volume de Infrastructură Globală și (B) Volume Specifice Aplicației.

### **2.2 Inventarul Volumelor Numite pentru Infrastructura Globală (Root Orchestrator)**

Aceste volume sunt critice pentru funcționarea întregii suite și trebuie definite în fișierul compose.yml de la rădăcina /var/www/GeniusSuite/.

#### **2.2.1 Baze de Date și Servicii de Date**

* **PostgreSQL 18 (Per-Aplicație):** Planul și solicitarea utilizatorului indică o bază de date per aplicație. Vom aloca un volum numit distinct pentru fiecare bază de date.  
  * **Volume:** gs\_pgdata\_identity, gs\_pgdata\_licensing, gs\_pgdata\_temporal, gs\_pgdata\_archify, gs\_pgdata\_cerniq, gs\_pgdata\_flowxify, gs\_pgdata\_iwms, gs\_pgdata\_mercantiq, gs\_pgdata\_numeriqo, gs\_pgdata\_triggerra, gs\_pgdata\_vettify, gs\_pgdata\_geniuserp, gs\_pgdata\_admin.  
  * **Cale Montare:** /var/lib/postgresql/data.  
* **Apache Kafka 4.1.0 (Broker):** Kafka necesită stocare persistentă pentru log-urile partițiilor sale.  
  * **Volum:** gs\_kafka\_data  
  * **Cale Montare:** /var/lib/kafka/data  
  * **Notă de Implementare:** La utilizarea volumelor persistente, variabila de mediu KAFKA\_BROKER\_ID trebuie setată la o valoare statică și constantă pentru a preveni coruperea clusterului la repornire.  
* **SuperTokens 11.2.0 (Auth Core):** Serviciul cp/identity utilizează SuperTokens, care necesită o bază de date (PostgreSQL în acest stack) pentru a stoca utilizatori, sesiuni și configurări multi-tenant.  
  * **Volum:** gs\_pgdata\_identity (definit anterior).  
* **Neo4j (Vettify Graph360):** Aplicația vettify.app utilizează Neo4j pentru vizualizarea relațiilor.  
  * **Volum:** gs\_neo4j\_data  
  * **Cale Montare:** /data (calea de date standard pentru Neo4j).

#### **2.2.2 Stack-ul de Observabilitate (Root Orchestrator)**

Întregul stack de observabilitate este, prin definiție, stateful.

* **Prometheus:** Necesită persistență pentru baza de date time-series (TSDB).  
  * **Volum:** gs\_prometheus\_data  
  * **Cale Montare:** /prometheus  
* **Loki:** Necesită persistență pentru stocarea chunk-urilor de log și a indexului.  
  * **Notă de Implementare:** O eroare frecventă de configurare este montarea doar a fișierului de configurare, ceea ce duce la pierderea completă a log-urilor la repornirea containerului. Volumul de date trebuie montat pe calea /loki.  
  * **Volum:** gs\_loki\_data  
  * **Cale Montare:** /loki  
* **Grafana:** Necesită persistență pentru baza sa de date internă (SQLite, care stochează configurări, utilizatori, dashboard-uri create din UI).  
  * **Volum:** gs\_grafana\_data  
  * **Cale Montare:** /var/lib/grafana  
* **Tempo:** Similar cu Loki, necesită stocare pentru trace-uri.  
  * **Volum:** gs\_tempo\_data  
  * **Cale Montare:** /tempo

#### **2.2.3 Infrastructura Edge (Root Orchestrator)**

* **Traefik ACME:** Serviciul proxy/traefik gestionează certificatele TLS/SSL prin ACME (Let's Encrypt). Pentru a preveni re-emiterea certificatelor la fiecare repornire și atingerea limitelor de rată ale autorității de certificare, fișierul acme.json trebuie să fie persistent.  
  * **Notă de Implementare:** O tentativă de a monta direct fișierul (ex: \-v./acme.json:/acme.json) va eșua, deoarece Docker va crea un *director* numit acme.json în container. Soluția corectă este montarea directorului părinte.  
  * **Volum:** gs\_traefik\_certs  
  * **Cale Montare (în docker-compose.yml):** volumes: \- gs\_traefik\_certs:/letsencrypt  
  * **Configurare Traefik (în traefik.yml):** certificatesResolvers.letsencrypt.acme.storage=/letsencrypt/acme.json

### **2.3 Inventarul Volumelor Numite pentru Aplicațiile Stand-Alone**

Aceste volume pot fi definite în fișierele compose.yml specifice aplicațiilor, dar este recomandat ca și acestea să fie definite în orchestratorul root pentru a beneficia de strategia de protecție (Partea 2).

* **Archify (DMS):** Aplicația archify.app gestionează documente. Pe lângă baza de date (gs\_pgdata\_archify), aplicația necesită stocare pentru fișierele brute (documente, versiuni, thumbnails, rezultate OCR), așa cum este indicat de structura storage/buckets/originals/.  
  * **Volum:** archify\_storage\_originals (presupunând stocare locală sau un backend tip MinIO)  
  * **Cale Montare:** /storage/originals (sau calea corespunzătoare configurată în backend-ul S3).

### **2.4 Tabel Strategic: Matricea de Alocare a Volumelor Numite (v1.0)**

Acest tabel servește drept "hartă a stării" (state map) pentru întreaga suită, detaliind ce volum gestionează ce date și cine este responsabil pentru definirea acestuia.

| Categorie Serviciu | Serviciu | Nume Volum Numit (Propus) | Cale Montare Container | Definit în (compose.yml) | Tip Date |
| :---- | :---- | :---- | :---- | :---- | :---- |
| Infrastructură (Date) | PostgreSQL (Global) | gs\_pgdata\_\[app\_name\] (ex: gs\_pgdata\_identity) | /var/lib/postgresql/data | Orchestrator Root | Bază de Date |
| Infrastructură (Broker) | Apache Kafka (1.3) | gs\_kafka\_data | /var/lib/kafka/data | Orchestrator Root | Log-uri Broker |
| Infrastructură (BPM) | Temporal (1.3) | gs\_pgdata\_temporal | /var/lib/postgresql/data | Orchestrator Root | Bază de Date (Stări) |
| Infrastructură (Graph) | Neo4j (Vettify 11.1) | gs\_neo4j\_data | /data | Orchestrator Root | Bază de Date (Graf) |
| Infrastructură (Edge) | Traefik (14.1) | gs\_traefik\_certs | /etc/traefik/acme | Orchestrator Root | Certificate SSL/TLS |
| Observabilitate | Prometheus (1.3) | gs\_prometheus\_data | /prometheus | Orchestrator Root | Bază de Date (TSDB) |
| Observabilitate | Loki (1.3) | gs\_loki\_data | /loki | Orchestrator Root | Log-uri (Chunks) |
| Observabilitate | Grafana (1.3) | gs\_grafana\_data | /var/lib/grafana | Orchestrator Root | Configurare / DB SQLite |
| Observabilitate | Tempo (1.3) | gs\_tempo\_data | /tempo | Orchestrator Root | Trace-uri |
| Aplicație (Storage) | Archify (4.1) | archify\_storage\_originals | /storage/originals | Orchestrator Root | Fișiere (Documente) |

## **3.0 Partea 2: Strategia de Protecție a Datelor pentru PostgreSQL**

Această secțiune se adresează direct solicitării critice de "separare clara a dockerului postgres pentru a evita ștergerea lui sau a db sau a datelor din el la o eventuală reconstruire, rebuild sau orice altă operațiune".

### **3.1 Principiul de Decuplare: Containere (Efemer) vs. Date (Persistent)**

Containerele Docker sunt proiectate pentru a fi efemere (fără stare). Orice dată scrisă în sistemul de fișiere intern, stratificat (union file system) al unui container este pierdută definitiv atunci când containerul este șters (de ex., la docker rm). Operațiuni comune de dezvoltare și deployment, cum ar fi docker compose up \--build \--force-recreate sau docker compose down urmat de up, vor distruge containerul vechi și, implicit, toate datele conținute.  
Soluția este utilizarea "volumelor numite", care sunt gestionate de motorul Docker, dar au un ciclu de viață complet *independent* de cel al oricărui container. Un container poate fi șters și recreat, iar noul container poate fi atașat la volumul numit existent, reluând exact de unde a rămas cel vechi.

### **3.2 Implementarea Volumelor Numite Externe în Modelul Hibrid**

Pericolul subsistă: comanda docker compose down \-v este concepută pentru a șterge containerele, rețelele *și volumele* (atât cele anonime, cât și cele numite) care sunt *definite în acel fișier docker-compose.yml*.  
Acest lucru creează un risc major în arhitectura hibridă a GeniusSuite. Un dezvoltator care lucrează la numeriqo.app ar putea rula docker compose down \-v în directorul numeriqo.app/compose/ cu intenția de a curăța mediul local. Dacă fișierul numeriqo.app/compose/docker-compose.yml *definește* volumul gs\_pgdata\_numeriqo, acea comandă l-ar distruge, ducând exact la pierderea de date pe care dorim să o prevenim.  
Soluția strategică exploatează arhitectura hibridă pentru a crea un mecanism de siguranță.  
**Strategia de Implementare Prescriptivă:**

1. **Definiția în Orchestratorul Root:** Toate volumele de date critice (întreaga listă de baze de date PostgreSQL, Kafka, Loki etc. din Partea 1\) *trebuie* definite exclusiv în secțiunea volumes: a fișierului compose.proxy.yml de la rădăcină (/var/www/GeniusSuite/compose.proxy.yml).  
   `# /var/www/GeniusSuite/compose.proxy.yml`  
   `version: "3.9"`

   `services:`  
     `#... servicii globale (Traefik, Observability, etc.)...`

   `volumes:`  
     `# Baze de date`  
     `gs_pgdata_identity:`  
     `gs_pgdata_licensing:`  
     `gs_pgdata_numeriqo:`  
     `gs_pgdata_archify:`  
     `#... restul volumelor PG...`

     `# Infrastructură`  
     `gs_kafka_data:`  
     `gs_neo4j_data:`  
     `gs_traefik_certs:`

     `# Observabilitate`  
     `gs_prometheus_data:`  
     `gs_loki_data:`  
     `#... etc.`

2. **Referențierea în Compose-ul Aplicației:** Fișierul docker-compose.yml al aplicației (ex: numeriqo.app/compose/docker-compose.yml) nu va *defini* volumul. Îl va *referenția* ca fiind extern, pre-existent.  
   `# /var/www/GeniusSuite/numeriqo.app/compose/docker-compose.yml`  
   `version: "3.9"`

   `services:`  
     `postgres_numeriqo:`  
       `image: postgres:18`  
       `environment:`  
         `#... variabile de mediu pentru DB...`  
       `volumes:`  
         `# Montează volumul pre-existent în container`  
         `- gs_pgdata_numeriqo:/var/lib/postgresql/data`  
       `networks:`  
         `- net_backing_services`  
         `- net_observability`

     `api_numeriqo:`  
       `#... definiție serviciu API...`  
       `networks:`  
         `- net_suite_internal`  
         `- net_backing_services`  
         `- net_observability`

   `volumes:`  
     `gs_pgdata_numeriqo:`  
       `# Punctul cheie: Se declară că Docker Compose NU gestionează`  
       `# ciclul de viață al acestui volum.`  
      `external: true`

   `networks:`  
     `# Se referă la rețelele definite în orchestratorul root`  
     `net_suite_internal:`  
       `external: true`  
     `net_backing_services:`  
       `external: true`  
     `net_observability:`  
       `external: true`

### **2.3 Analiza Scenariilor Operaționale (Demonstrarea Siguranței)**

Această strategie decuplează ciclul de viață al datelor de operațiunile de dezvoltare zilnice:

* **Scenariul 1: Rebuild Aplicație (ex: docker compose up \--build \-d în numeriqo.app/compose/)**  
  * **Rezultat:** Docker va recrea containerul api\_numeriqo și (dacă este necesar) postgres\_numeriqo. La pornirea noului container postgres\_numeriqo, Docker va reatașa automat volumul numit existent gs\_pgdata\_numeriqo. **Datele sunt în siguranță.**  
* **Scenariul 2: Curățare Aplicație (ex: docker compose down \-v în numeriqo.app/compose/)**  
  * **Rezultat:** Docker va șterge containerele api\_numeriqo și postgres\_numeriqo. Va încerca să șteargă volumele definite *în acest fișier*. Deoarece gs\_pgdata\_numeriqo este marcat ca external: true, Docker *nu îl va șterge*. **Datele sunt în siguranță.** Aceasta este îndeplinirea directă a cerinței utilizatorului.  
* **Scenariul 3: Distrugere Totală a Mediului (ex: docker compose down \-v în rădăcina /var/www/GeniusSuite/)**  
  * **Rezultat:** Această comandă, executată pe fișierul compose.yml care *definește* volumele (fără external: true), le va șterge.  
  * **Concluzie:** Acest lucru este un comportament de dorit. Strategia mută responsabilitatea distrugerii datelor de la o operațiune la nivel de aplicație (frecventă, riscantă) la o operațiune la nivel de orchestrator (rară, deliberată și care necesită acces la rădăcina proiectului).

## **3.0 Partea 3: Implementarea Topologiei de Rețea (Model Zero-Trust Intern)**

Strategia de rețea implementează formal modelul de securitate și segmentare definit în documentul Strategii de Fișiere.env și Porturi. Aceasta se bazează pe un model "Zero-Trust" la nivel de rețea, în care serviciile au acces *doar* la segmentele de rețea strict necesare pentru funcționarea lor.  
Vor fi definite patru rețele bridge principale în orchestratorul root (compose.yml), care vor fi partajate cu toate serviciile prin directiva external: true (similar cu volumele).

### **3.1 Configurare net\_edge (Rețeaua Publică/DMZ)**

* **Scop:** Singura rețea expusă la internet. Gestionează tot traficul de intrare.  
* **Membri:** proxy/traefik (care expune porturile 80 și 443 ale host-ului).  
* **Flux:** Internet \-\> Host (Port 443\) \-\> proxy/traefik.

### **3.2 Configurare net\_suite\_internal (Rețeaua API)**

* **Scop:** Conectează proxy-ul la serviciile de aplicație (API-uri și BFF-uri). Aceasta este rețeaua pentru traficul HTTP/gRPC intern, post-autentificare.  
* **Membri:** proxy/traefik, gateway/, și *toate* serviciile API/BFF (ex: cp/identity, archify.app/api, vettify.app/api).  
* **Flux:** proxy/traefik \-\> gateway/ \-\> archify.app/api.  
* **Regulă Zero-Trust:** Niciun serviciu de date (PostgreSQL, Kafka) nu trebuie să fie atașat vreodată la această rețea.

### **3.3 Configurare net\_backing\_services (Rețeaua Securizată de Date)**

* **Scop:** Rețea complet izolată pentru servicii de infrastructură critice (baze de date, brokeri de mesaje). Nu este accesibilă direct din net\_edge.  
* **Membri:** db/PostgreSQL (toate instanțele), Broker/Kafka , BPM/Temporal , Auth Core/SuperTokens. De asemenea, serviciile API care au nevoie de acces *direct* la aceste date (ex: gateway/, archify.app/api, vettify.app/api).  
* **Flux:** archify.app/api \-\> db/PostgreSQL (pe rețeaua net\_backing\_services).  
* **Regulă Zero-Trust:** proxy/traefik NU trebuie să aibă acces la această rețea.

### **3.4 Configurare net\_observability (Rețeaua de Management)**

* **Scop:** Permite stack-ului de observabilitate (Prometheus) să colecteze (scrape) metrici și log-uri (via Promtail) de la toate celelalte servicii.  
* **Membri:** Stack-ul shared/observability (Prometheus, Loki, OTEL) și *toate* celelalte servicii (API-uri, baze de date, Kafka, Traefik) pentru a-și expune endpoint-urile de metrici (ex: /metrics) sau log-uri.

### **3.5 Tabel de Implementare: Matricea de Conectivitate a Serviciilor**

Acest tabel definește alocarea prescriptivă a fiecărui serviciu la rețelele definite.

| Serviciu | net\_edge (Public) | net\_suite\_internal (API) | net\_backing\_services (Date) | net\_observability (Monitorizare) |
| :---- | :---- | :---- | :---- | :---- |
| **Infrastructură** |  |  |  |  |
| proxy/traefik | **\[ X \]** | **\[ X \]** | \[ \- \] | **\[ X \]** |
| gateway/bff | \[ \- \] | **\[ X \]** | **\[ X \]** | **\[ X \]** |
| db/postgres\_\* (toate) | \[ \- \] | \[ \- \] | **\[ X \]** | **\[ X \]** |
| Broker/kafka | \[ \- \] | \[ \- \] | **\[ X \]** | **\[ X \]** |
| BPM/temporal | \[ \- \] | \[ \- \] | **\[ X \]** | **\[ X \]** |
| db/neo4j | \[ \- \] | \[ \- \] | **\[ X \]** | **\[ X \]** |
| **Observabilitate** |  |  |  |  |
| obs/prometheus | \[ \- \] | \[ \- \] | \[ \- \] | **\[ X \]** |
| obs/loki | \[ \- \] | \[ \- \] | \[ \- \] | **\[ X \]** |
| obs/otel-collector | \[ \- \] | \[ \- \] | \[ \- \] | **\[ X \]** |
| **Control Plane (API)** |  |  |  |  |
| cp/identity | \[ \- \] | **\[ X \]** | **\[ X \]** | **\[ X \]** |
| cp/licensing | \[ \- \] | **\[ X \]** | **\[ X \]** | **\[ X \]** |
| cp/suite-admin (API) | \[ \- \] | **\[ X \]** | **\[ X \]** | **\[ X \]** |
| **Aplicații (API)** |  |  |  |  |
| archify.app (API) | \[ \- \] | **\[ X \]** | **\[ X \]** | **\[ X \]** |
| numeriqo.app (API) | \[ \- \] | **\[ X \]** | **\[ X \]** | **\[ X \]** |
| vettify.app (API) | \[ \- \] | **\[ X \]** | **\[ X \]** | **\[ X \]** |
| i-wms.app (API) | \[ \- \] | **\[ X \]** | **\[ X \]** | **\[ X \]** |

## **4.0 Partea 4: Automatizarea Backup-ului și Retenției (Strategia de 7 Zile)**

Această strategie răspunde cerinței pentru "backup automatizat al volumelor zilnic cu păstrare a 7 zile/backupuri pentru restore și ștergere recursiva a celorlalte mai vechi de 7 zile".

### **4.1 Arhitectura de Backup: Containerul "Sidecar" Dedicat**

O soluție bazată pe cron la nivelul sistemului de operare gazdă este fragilă, neportabilă și încalcă principiile de containerizare. Strategia recomandată este utilizarea unui container "sidecar" dedicat, numit backup-manager, care rulează alături de baza de date.  
Acest container va fi definit în orchestratorul root (compose.proxy.yml) și va rula scripturile pg-dump.ts și rotate.ts menționate în planul de suită.  
**Definiție docker-compose.yml (extras pentru backup-manager):**  
`# /var/www/GeniusSuite/compose.proxy.yml`

`services:`  
  `#... alte servicii...`

  `backup-manager:`  
    `# Presupunând o imagine custom construită din 'scripts/db/backups/'`  
    `# care conține Node.js 24, pnpm și postgresql-client`  
    `build:`  
      `context:.`  
      `dockerfile:./scripts/db/backups/Dockerfile`  
    `restart: always`  
    `networks:`  
      `# CRITIC: Trebuie să aibă acces la rețeaua bazelor de date`  
      `- net_backing_services`  
    `volumes:`  
      `# Volumul numit unde vor fi stocate fizic arhivele`  
      `- gs_backups:/backups`  
      `# Necesar pentru a rula comenzi 'docker exec' pe containerele țintă`  
      `- /var/run/docker.sock:/var/run/docker.sock:ro`  
    `environment:`  
      `# Rulează zilnic la 02:00 [span_27](start_span)[span_27](end_span)`  
      `SCHEDULE: "0 2 * * *"`  
      `# Politica de retenție solicitată de utilizator [span_28](start_span)[span_28](end_span)[span_29](start_span)[span_29](end_span)`  
      `RETENTION_DAYS: 7`  
      `BACKUP_DIR: /backups`  
      `# Variabile necesare pentru pg_dump`  
      `PG_USER: ${SUITE_DB_POSTGRES_USER}`  
      `PG_PASSWORD: ${SUITE_DB_POSTGRES_PASS}`  
    `# Comanda de start rulează un scheduler intern (ex: node-cron)`  
    `# care execută scripturile 'pg-dump.ts' și 'rotate.ts'`  
    `command: pnpm start`

`volumes:`  
  `#... alte volume...`  
  `gs_backups:`

### **4.2 Detalierea Scriptului de Backup (Implementarea pg-dump.ts)**

Scriptul scripts/db/backups/pg-dump.ts va rula în interiorul containerului backup-manager. Logica sa principală este următoarea:

1. **Descoperire Ținte:** Scriptul va folosi API-ul Docker (prin socket-ul montat) pentru a găsi toate containerele care rulează și care au o etichetă specifică (de ex., label=gs.backup.postgres=true). Această etichetă va fi adăugată la definiția fiecărui serviciu PostgreSQL în fișierele compose.yml.  
2. **Execuție pg\_dump:** Pentru fiecare container țintă, scriptul va executa o comandă docker exec, similar logicii din scripturile de backup tradiționale.  
   `// Logică conceptuală în pg-dump.ts`  
   `const containerName = "postgres_numeriqo"; // Descoperit prin etichetă`  
   `const dbName = "numeriqo_db";`  
   ``const backupFile = `/backups/${dbName}-${new Date().toISOString().split('T')}.sql.gz`;``

   `// Comanda execută pg_dump ÎN containerul țintă și pipe-uiește`  
   `// rezultatul (gzip) în directorul /backups al containerului backup-manager.`  
   ``const command = `docker exec ${containerName} pg_dump -U ${process.env.PG_USER} -d ${dbName} --format=custom | gzip > ${backupFile}`;``

   `//... execută comanda...`

3. **Variabile de Mediu:** Scriptul va utiliza variabilele de mediu (ex: PG\_USER, PG\_PASSWORD) pentru a se autentifica la pg\_dump non-interactiv.

### **4.3 Detalierea Politicii de Retenție (Implementarea rotate.ts)**

Scriptul scripts/db/backups/rotate.ts rulează după finalizarea pg-dump.ts, ca parte a aceleiași sarcini programate.

1. **Citire Politică:** Scriptul va citi variabilele de mediu RETENTION\_DAYS (setat la 7\) și BACKUP\_DIR (setat la /backups).  
2. **Execuție Curățare:** Scriptul va implementa logica echivalentă comenzii find din Linux, așa cum este documentat în strategiile de retenție.  
   `// Logică conceptuală în rotate.ts`  
   `// Echivalentul Node.js pentru:`  
   `// find /backups -name "*.sql.gz" -mtime +7 -delete`

   `const retentionDays = parseInt(process.env.RETENTION_DAYS, 10);`  
   `const backupDir = process.env.BACKUP_DIR;`

   `//... logică Node.js (fs.readdir, fs.stat, fs.unlink)...`  
   `// pentru a șterge fișierele mai vechi decât 'retentionDays'`

Acest proces îndeplinește exact cerința utilizatorului pentru "ștergere recursiva a celorlalte mai vechi de 7 zile".

### **4.4 Proceduri de Validare a Restaurării**

Un backup nu este complet fără o strategie de restaurare. Planul de suită include, în mod corect, un script scripts/db/backups/pg-restore.ts. Acest script trebuie să fie capabil să:

1. Listeze backup-urile disponibile din volumul gs\_backups.  
2. Să preia un fișier de backup specificat.  
3. Să creeze o nouă bază de date temporară (ex: numeriqo\_restore\_test).  
4. Să execute gunzip și pg\_restore pentru a popula baza de date temporară.

Această procedură este esențială pentru exercițiile de recuperare în caz de dezastru (Disaster Recovery drills).

## **5.0 Partea 5: Mentenanța Stocării și Igiena Sistemului (Strategia de Pruning)**

Această secțiune se adresează cerințelor de "curățare automata a volumelor reziduale/builduri vechi la fiecare build nou" și "nu vreau sa incarc spațiul de stocare cu imagini reziduale nefolosite".  
Aceste solicitări sunt separate în trei probleme distincte, fiecare cu o soluție tehnică specifică: (A) Cache-ul de Build, (B) Volumele Reziduale și (C) Imaginile Reziduale.

### **5.1 Strategia 1: Curățarea Cache-ului de Build ("builduri vechi")**

* **Problemă:** "builduri vechi" se referă la cache-ul Docker BuildKit (straturile intermediare ale imaginii) care se acumulează pe *runner-ii CI* după fiecare build. Acestea pot consuma sute de GB.  
* **Soluție:** O comandă de curățare post-build în pipeline-ul CI/CD.  
* **Implementare (în .github/workflows/ci.yml):**  
    `#... după pasul de 'docker build'...`

    `- name: Prune Docker Builder Cache`  
      `if: always() # Rulează chiar dacă build-ul eșuează`  
      `run: docker builder prune -f`  
  Comanda docker builder prune \-f șterge tot cache-ul de build neutilizat, eliberând spațiu pe runner-ul CI la fiecare execuție, îndeplinind cerința "la fiecare build nou".

### **5.2 Strategia 2: Curățarea Volumelor Reziduale**

* **Problemă:** "volumele reziduale" sunt, de obicei, volume *anonime* create de containere (de ex., pentru stocare temporară) și care nu sunt șterse la docker compose down.  
* **Soluție (Dezvoltare):** Scriptul scripts/compose/down.ts trebuie să fie un wrapper standardizat pentru docker compose down \-v. Flag-ul \-v instruiește Compose să șteargă volumele *anonime* atașate containerelor din acel fișier. Volumele noastre de date critice (ex: gs\_pgdata\_numeriqo) sunt *protejate* de această comandă prin strategia external: true (Partea 2).  
* **Soluție (Mentenanță Host):** Scriptul scripts/compose/volumes.ts trebuie să fie un wrapper pentru docker volume prune \-f. Această comandă curăță *toate* volumele locale (inclusiv cele numite) care nu sunt atașate la *niciun* container. Este o comandă de mentenanță mai agresivă, care trebuie rulată periodic pe host.

### **5.3 Strategia 3: Curățarea Imaginilor Reziduale ("imagini reziduale nefolosite")**

* **Problemă:** Pe serverele de producție și de build, imaginile vechi (ex: numeriqo-api:v1.1.0, numeriqo-api:v1.1.1) se acumulează, consumând spațiu pe disc.  
* **Soluție:** O sarcină cron la nivel de sistem de operare gazdă (sau un timer systemd) care execută o curățare periodică.  
* **Implementare (Script la nivel de Host):**  
  `#!/bin/bash`  
  `# /etc/cron.daily/docker-cleanup`

  `# Șterge toate imaginile care nu sunt folosite de un container`  
  `# ȘI sunt mai vechi de 7 zile (168 ore).`  
  `# -a = --all (include imaginile ne-dangling)`  
  `# -f = --force (nu cere confirmare)`  
  `# --filter "until=168h" = păstrează imaginile din ultimele 7 zile [span_44](start_span)[span_44](end_span)`

  `/usr/bin/docker image prune -a -f --filter "until=168h"`  
  Această strategie îndeplinește cerința de a nu încărca spațiul de stocare, oferind în același timp o fereastră de 7 zile pentru un rollback rapid la o imagine anterioară, dacă este necesar.

## **6.0 Partea 6: Rezumat Strategic și Recomandări de Implementare**

Strategia de infrastructură Docker propusă îndeplinește toate cerințele tehnice specificate, oferind o fundație robustă, sigură și mentenabilă pentru suita GeniusERP.  
**Recomandări Prescriptive pentru Implementare:**

1. **Protecția Volumelor (Partea 2):** Se va adopta imediat și fără excepție strategia external: true. Toate volumele stateful trebuie *definite* în compose.yml de la rădăcină și *referențiate* ca external în fișierele compose.yml ale aplicațiilor. Aceasta este cea mai importantă măsură de protecție a datelor.  
2. **Segmentarea Rețelei (Partea 3):** Se va implementa topologia cu patru rețele (net\_edge, net\_suite\_internal, net\_backing\_services, net\_observability). Matricea de Conectivitate (Tabelul 3.5) va fi utilizată ca referință strictă pentru atașarea containerelor la rețele.  
3. **Automatizarea Backup-ului (Partea 4):** Se va prioritiza implementarea containerului backup-manager (sidecar), deoarece acesta automatizează o cerință critică de business (backup și retenție de 7 zile) într-un mod portabil și aliniat cu principiile de containerizare.  
4. **Automatizarea Igienei (Partea 5):** Se vor implementa imediat scripturile de curățare: docker builder prune \-f în pipeline-ul CI și docker image prune \-a \-f \--filter "until=168h" ca sarcină cron zilnică pe toate host-urile Docker.

Prin adoptarea acestor strategii, infrastructura GeniusSuite va atinge un echilibru între flexibilitatea necesară dezvoltării (oferită de modelul hibrid) și robustețea, securitatea și siguranța datelor cerute de un mediu de producție enterprise.

### **Works cited**

1. Docker Persistent Storage Solutions by Portworx — [https://portworx.com/use-case/docker-persistent-storage/](https://portworx.com/use-case/docker-persistent-storage/)
2. Kafka Docker: Setup Guide & Best Practices (AutoMQ) — [https://www.automq.com/blog/kafka-docker-setup-guide-best-practices](https://www.automq.com/blog/kafka-docker-setup-guide-best-practices)
3. Traefik, Let'sEncrypt and acme.json Configuration Problems (William Hayes) — [https://williamhayes.medium.com/traefik-letsencrypt-and-acme-json-configuration-problems-5780c914351d](https://williamhayes.medium.com/traefik-letsencrypt-and-acme-json-configuration-problems-5780c914351d)
4. Docker – How to Persist Prometheus Data for Reliable Monitoring (SigNoz) — [https://signoz.io/guides/how-to-persist-data-in-prometheus-running-in-a-docker-container/](https://signoz.io/guides/how-to-persist-data-in-prometheus-running-in-a-docker-container/)
5. Loki Logs Clear After Container Restart (Reddit) — [https://www.reddit.com/r/grafana/comments/1h2p27h/loki_logs_clear_after_container_restart/](https://www.reddit.com/r/grafana/comments/1h2p27h/loki_logs_clear_after_container_restart/)
6. How to Persist Data in a Dockerized Postgres Database Using Volumes? (DEV Community) — [https://dev.to/iamrj846/how-to-persist-data-in-a-dockerized-postgres-database-using-volumes-15f0](https://dev.to/iamrj846/how-to-persist-data-in-a-dockerized-postgres-database-using-volumes-15f0)
7. Understanding Docker Volumes and Persistent Storage (Medium) — [https://medium.com/@jonas.granlund/docker-volumes-and-persistent-storage-the-complete-guide-71a100875b6c](https://medium.com/@jonas.granlund/docker-volumes-and-persistent-storage-the-complete-guide-71a100875b6c)
8. How to Persist Data in a Dockerized Postgres Database Using Volumes (Stack Overflow) — [https://stackoverflow.com/questions/41637505/how-to-persist-data-in-a-dockerized-postgres-database-using-volumes](https://stackoverflow.com/questions/41637505/how-to-persist-data-in-a-dockerized-postgres-database-using-volumes)
9. Setting Up a Kafka Cluster Using Docker Compose (Medium) — [https://medium.com/@darshak.kachchhi/setting-up-a-kafka-cluster-using-docker-compose-a-step-by-step-guide-a1ee5972b122](https://medium.com/@darshak.kachchhi/setting-up-a-kafka-cluster-using-docker-compose-a-step-by-step-guide-a1ee5972b122)
10. Persist Data Outside of Container (wurstmeister/kafka-docker Issue #672) — [https://github.com/wurstmeister/kafka-docker/issues/672](https://github.com/wurstmeister/kafka-docker/issues/672)
11. Grafana Loki Storage Documentation — [https://grafana.com/docs/loki/latest/configure/storage/](https://grafana.com/docs/loki/latest/configure/storage/)
12. LetsEncrypt Cert in Volume Does Not Persist (traefik Issue #6487) — [https://github.com/traefik/traefik/issues/6487](https://github.com/traefik/traefik/issues/6487)
13. Do You Need docker-compose down Every Time? (Reddit) — [https://www.reddit.com/r/devops/comments/ovkhwa/do_you_need_to_do_dockercompose_down_every_time/](https://www.reddit.com/r/devops/comments/ovkhwa/do_you_need_to_do_dockercompose_down_every_time/)
14. Persisting Container Data (Docker Docs) — [https://docs.docker.com/get-started/docker-concepts/running-containers/persisting-container-data/](https://docs.docker.com/get-started/docker-concepts/running-containers/persisting-container-data/)
15. docker compose rm (Docker Docs) — [https://docs.docker.com/reference/cli/docker/compose/rm/](https://docs.docker.com/reference/cli/docker/compose/rm/)
16. Remove a Named Volume with docker-compose? (Stack Overflow) — [https://stackoverflow.com/questions/45511956/remove-a-named-volume-with-docker-compose](https://stackoverflow.com/questions/45511956/remove-a-named-volume-with-docker-compose)
17. Using the Docker Compose Down Command Effectively (LabEx) — [https://labex.io/tutorials/docker-using-the-docker-compose-down-command-effectively-400128](https://labex.io/tutorials/docker-using-the-docker-compose-down-command-effectively-400128)
18. Confused with Docker, Postgres, and Automated Backups (Reddit) — [https://www.reddit.com/r/docker/comments/1jgx896/confused_with_docker_postgres_and_automated/](https://www.reddit.com/r/docker/comments/1jgx896/confused_with_docker_postgres_and_automated/)
19. Musab520/pgbackup-sidecar (GitHub) — [https://github.com/Musab520/pgbackup-sidecar](https://github.com/Musab520/pgbackup-sidecar)
20. Automated PostgreSQL Backups in Docker (Serversinc) — [https://serversinc.io/blog/automated-postgresql-backups-in-docker-complete-guide-with-pg-dump/](https://serversinc.io/blog/automated-postgresql-backups-in-docker-complete-guide-with-pg-dump/)
21. Automated/Cron Backups of Postgres Database? (Docker Community Forums) — [https://forums.docker.com/t/automated-cron-backups-of-postgres-database/6338](https://forums.docker.com/t/automated-cron-backups-of-postgres-database/6338)
22. Build Garbage Collection (Docker Docs) — [https://docs.docker.com/build/cache/garbage-collection/](https://docs.docker.com/build/cache/garbage-collection/)
23. Is There a Way to Clean Docker Build Cache? (Stack Overflow) — [https://stackoverflow.com/questions/65405562/is-there-a-way-to-clean-docker-build-cache](https://stackoverflow.com/questions/65405562/is-there-a-way-to-clean-docker-build-cache)
24. How To Clean Up Docker With Prune (Vultr Docs) — [https://docs.vultr.com/how-to-clean-up-docker-with-prune](https://docs.vultr.com/how-to-clean-up-docker-with-prune)
25. Prune Unused Docker Objects (Docker Docs) — [https://docs.docker.com/engine/manage-resources/pruning/](https://docs.docker.com/engine/manage-resources/pruning/)
26. docker volume prune (Docker Docs) — [https://docs.docker.com/reference/cli/docker/volume/prune/](https://docs.docker.com/reference/cli/docker/volume/prune/)
27. How to Ensure Successful Pruning of Docker Resources (LabEx) — [https://labex.io/tutorials/docker-how-to-ensure-successful-pruning-of-docker-resources-411537](https://labex.io/tutorials/docker-how-to-ensure-successful-pruning-of-docker-resources-411537)
28. How to Remove Docker Images Created 7 Days Ago Automatically? (Stack Overflow) — [https://stackoverflow.com/questions/50737059/how-to-remove-docker-images-which-created-7-days-ago-automatically](https://stackoverflow.com/questions/50737059/how-to-remove-docker-images-which-created-7-days-ago-automatically)
