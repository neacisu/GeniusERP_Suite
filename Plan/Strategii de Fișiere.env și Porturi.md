# **Raport Strategic: Guvernanța Configurațiilor de Mediu și a Rețelelor pentru Suita GeniusERP**

Acest document stabilește standardele tehnice prescriptive pentru managementul configurațiilor de mediu (secrete, variabile) și alocarea porturilor de rețea (interne și externe) pentru întreaga suită de aplicații GeniusERP. Aceste strategii sunt fundamentale pentru a asigura securitatea, scalabilitatea și mentenabilitatea sistemului, așa cum este definit în planul arhitectural (GeniusERP\_Suite\_Plan\_v1.0.5).

## **Partea 1: Strategia Standardizată pentru Managementul Configurațiilor și Secretelor (Fișiere .env)**

### **1.1. Principii Fundamentale și Arhitectura Configurației**

Arhitectura GeniusERP, așa cum este detaliată în planul de suită , se bazează pe un "model hibrid" de orchestrare Docker. Acest model utilizează atât fișiere docker-compose.yml la nivel de aplicație (pentru izolare și ownership), cât și un compose.yml orchestrator la rădăcină (pentru gestionarea rețelelor partajate, Traefik și observabilitate).  
Acest model de orchestrare impune, prin necesitate, o strategie de configurare la fel de hibridă:

1. **Configurații Specifice Aplicației:** Fiecărui serviciu sau aplicație (de exemplu, archify.app) îi trebuie propriile secrete izolate (de exemplu, cheia sa de conectare la baza de date).  
2. **Configurații Partajate (Globale):** Orchestratorul rădăcină și multiple servicii trebuie să partajeze configurații comune (de exemplu, adresa broker-ului Kafka, adresa serverului Temporal sau punctele finale ale stack-ului de observabilitate).

Strategia .env propusă abordează ambele cerințe, urmând principiul "12-Factor App" de separare strictă a configurației de cod. Aceasta este esențială pentru portabilitatea și securitatea containerelor definite în stack-ul tehnologic.  
Inventarul riscurilor de securitate și configurare, derivat din analiza tehnologiilor din planul suitei, impune gestionarea externă a următoarelor tipuri de informații sensibile :

* **Secrete Baze de Date:** String-uri de conexiune, utilizatori și parole pentru instanțele PostgreSQL 18\.  
* **Secrete Brokeri:** Adrese de bootstrap și credențiale SASL (dacă este cazul) pentru Apache Kafka 4.1.0.  
* **Secrete de Autentificare:** Chei de conexiune, chei API și secrete JWT/OIDC pentru nucleul SuperTokens 11.2.0 (cp/identity).  
* **Chei API Terțe:** Secrete, token-uri și chei pentru toate integrările definite în shared/integrations/, incluzând, dar fără a se limita la, ANAF, BNR, Revolut, Shopify, Stripe, PandaDoc și diverși furnizori AI (cp/ai-hub).  
* **Secrete Interne:** Chei de criptare sau token-uri de serviciu utilizate pentru comunicarea internă (de exemplu, securizarea cp/licensing).  
* **Configurări de Rețea:** Toate porturile, host-urile și URL-urile interne și externe, care fac obiectul Părții 2 a acestui raport.

### **1.2. Strategia de Denumire a Fișierelor .env**

Pentru a gestiona modelul hibrid și a preveni coliziunile de nume, se adoptă o convenție de numire strictă și unică. Formatul utilizează un prefix cu punct, bazat pe calea componentei în monorepo-ul NX, așa cum este definit în structura de directoare.  
**Convenție:** .\<cale\_relativa\_fara\_slash\>.env  
Această convenție asigură unicitatea și permite o regulă gitignore globală simplă (de exemplu, \*.env), excluzând astfel toate fișierele de mediu, cu excepția șabloanelor (de exemplu, \*.env.example sau env/vault.template.hcl identificate în plan ).  
Tabelul 1 prezintă inventarul exhaustiv al fișierelor de mediu mapate la componentele definite în planul suitei.  
**Tabelul 1: Convenția de Denumire a Fișierelor .env**

| Categorie | Cale Monorepo | Nume Fișier .env (Strategie) |
| :---- | :---- | :---- |
| General (Root) | /var/www/GeniusSuite/ | .suite.general.env |
| Infrastructură | gateway/ | .gateway.env |
| Infrastructură | proxy/ | .proxy.env |
| Infrastructură | shared/observability/ | .observability.env |
| Control Plane | cp/suite-shell/ | .cp.suite-shell.env |
| Control Plane | cp/suite-admin/ | .cp.suite-admin.env |
| Control Plane | cp/suite-login/ | .cp.suite-login.env |
| Control Plane | cp/identity/ | .cp.identity.env |
| Control Plane | cp/licensing/ | .cp.licensing.env |
| Control Plane | cp/analytics-hub/ | .cp.analytics-hub.env |
| Control Plane | cp/ai-hub/ | .cp.ai-hub.env |
| Aplicație | archify.app/ | .archify.env |
| Aplicație | cerniq.app/ | .cerniq.env |
| Aplicație | flowxify.app/ | .flowxify.env |
| Aplicație | i-wms.app/ | .i-wms.env |
| Aplicație | mercantiq.app/ | .mercantiq.env |
| Aplicație | numeriqo.app/ | .numeriqo.env |
| Aplicație | triggerra.app/ | .triggerra.env |
| Aplicație | vettify.app/ | .vettify.env |
| Aplicație | geniuserp.app/ | .geniuserp.env |

### **1.3. Strategia de Denumire a Variabilelor (Placeholder Convention)**

Utilizarea variabilelor generice (de exemplu, DATABASE\_URL, PORT) în fișiere .env multiple va duce la coliziuni de variabile de mediu atunci când sunt încărcate de orchestratorul root sau în procesele de CI/CD.  
Pentru a preveni acest lucru, se impune o convenție de numire standardizată, cu prefix unic, pentru *toate* variabilele de mediu.  
**Format Convenție:** \<PREFIX\>\_\<CATEGORIE\>\_\<NUME\_VARIABILA\>  
Această structură asigură că fiecare variabilă este unică la nivel global și auto-descriptivă.  
Tabelul 2 definește prefixele și categoriile standardizate.  
**Tabelul 2: Convenția Prefixelor și Categoriilor pentru Variabilele de Mediu**

| Partea A: Prefixe de Componentă (Eșantion) |  |
| :---- | :---- |
| **Prefix** | \*\*Componentă \*\* |
| SUITE\_ | .suite.general.env (Configurații Globale) |
| CP\_SHELL\_ | cp/suite-shell/ |
| CP\_ADMIN\_ | cp/suite-admin/ |
| CP\_LOGIN\_ | cp/suite-login/ |
| CP\_IDT\_ | cp/identity/ |
| CP\_LIC\_ | cp/licensing/ |
| CP\_ANLY\_ | cp/analytics-hub/ |
| CP\_AI\_ | cp/ai-hub/ |
| ARCHY\_ | archify.app/ |
| CERNIQ\_ | cerniq.app/ |
| FLOWX\_ | flowxify.app/ |
| IWMS\_ | i-wms.app/ |
| MERCQ\_ | mercantiq.app/ |
| NUMQ\_ | numeriqo.app/ |
| TRIGR\_ | triggerra.app/ |
| VETFY\_ | vettify.app/ |
| GENERP\_ | geniuserp.app/ |
| GW\_ | gateway/ |
| PROXY\_ | proxy/ |
| OBS\_ | shared/observability/ |
|  |  |
| **Partea B: Categorii Logice de Variabile** |  |
| **Categorie** | **Descriere** |
| DB\_ | Baze de date (de exemplu, PostgreSQL, Redis) |
| MQ\_ | Message Queue / Broker (de exemplu, Kafka) |
| BPM\_ | Business Process Management (de exemplu, Temporal) |
| AUTH\_ | Autentificare/Autorizare (de exemplu, SuperTokens, JWT, OIDC) |
| API\_ | Chei API și Endpoints pentru servicii terțe (de exemplu, ANAF, Revolut) |
| SVC\_ | Service URLs: Adrese interne pentru *alte* servicii din suită |
| APP\_ | Configurații specifice aplicației (Porturi, Secrete interne, Mod de operare) |
| OBS\_ | Observabilitate (de exemplu, Endpoints pentru OTEL, Loki) |

### **1.4. Catalogul Variabilelor de Mediu (Șabloane per Componentă)**

Următoarele șabloane definesc setul minim de variabile de mediu necesare pentru componentele cheie ale suitei, pe baza tehnologiilor identificate în. Acestea vor servi drept bază pentru fișierele \*.env.example și pentru configurarea Vault.

#### **Șablon 1: .suite.general.env (Configurații Globale/Partajate)**

Aceste variabile sunt destinate orchestratorului rădăcină (/var/www/GeniusSuite/compose.yml) și pot fi partajate cu toate serviciile ca referințe comune.  
`#######################################################`  
`# SUITA GENIUSSUITE - CONFIGURAȚII GLOBALE`  
`# Sursă:  (Stack tehnologic, Control Plane)`  
`#######################################################`

`# -- DOMENIU ȘI REȚEA --`  
`# Domeniul principal folosit de Proxy/Traefik`  
`SUITE_APP_DOMAIN=geniuserp.app`

`# -- SERVICII DE BAZĂ PARTAJATE (BACKING SERVICES) --`

`# Bază de Date Principală`  
`SUITE_DB_POSTGRES_HOST=postgres_server`  
`SUITE_DB_POSTGRES_USER=suite_admin`  
`SUITE_DB_POSTGRES_PASS=ReplaceMeWithGlobalDBPassword`

`# Broker`  
`SUITE_MQ_KAFKA_BROKERS=kafka:9092`  
`SUITE_MQ_KAFKA_USER=ReplaceMeWithKafkaUser`  
`SUITE_MQ_KAFKA_PASS=ReplaceMeWithKafkaPassword`

`# BPM`  
`SUITE_BPM_TEMPORAL_HOST_PORT=temporal:7233`

`# -- OBSERVABILITATE  --`  
`# Puncte finale pentru colectarea telemetriei`  
`SUITE_OBS_OTEL_COLLECTOR_GRPC_URL=http://otel-collector:3200`  
`SUITE_OBS_OTEL_COLLECTOR_HTTP_URL=http://otel-collector:3200`  
`SUITE_OBS_LOKI_URL=http://loki:3100`

#### **Șablon 2: .cp.identity.env (Serviciu Critic \- Auth)**

Acest fișier configurează serviciul cp/identity, care rulează SuperTokens și provider-ul OIDC.  
`#######################################################`  
`# CONTROL PLANE: IDENTITY (CP_IDT)`  
`# Sursă:  (cp/identity, SuperTokens)`  
`#######################################################`

`# -- CONFIGURARE APLICAȚIE --`  
`# Portul intern al API-ului OIDC/Fastify (Alocat în Partea 2)`  
`CP_IDT_APP_PORT=6250`  
`CP_IDT_APP_NODE_ENV=production`

`# -- BAZA DE DATE (Specifică 'identity') --`  
`CP_IDT_DB_POSTGRES_URL=postgresql://identity_user:ReplaceMe@postgres_server:5432/identity_db`

`# -- AUTENTIFICARE (SuperTokens Core)  --`  
`# Adresa nucleului SuperTokens (Alocat în Partea 2)`  
`CP_IDT_AUTH_SUPERTOKENS_CONNECTION_URI=http://supertokens-core:3567`  
`CP_IDT_AUTH_SUPERTOKENS_API_KEY=ReplaceMeWithSuperTokensAPIKey`

`# -- SECRETE JWT/OIDC  --`  
`CP_IDT_AUTH_JWT_SECRET=ReplaceMeWithStrongJWTSecretKey`  
`CP_IDT_AUTH_OIDC_ISSUER_URL=https://identity.geniuserp.app`  
`CP_IDT_AUTH_OIDC_CLIENT_ID=genius_suite_client`  
`CP_IDT_AUTH_OIDC_CLIENT_SECRET=ReplaceMeWithOIDCClientSecret`

#### **Șablon 3: .numeriqo.env (Aplicație Stand-Alone cu Integrări)**

Acest fișier configurează numeriqo.app, baza sa de date specifică și integrările sale unice (ANAF, Revolut, etc.).  
`#######################################################`  
`# APLICAȚIE: NUMERIQO (NUMQ)`  
`# Sursă:  (numeriqo.app, shared/integrations)`  
`#######################################################`

`# -- CONFIGURARE APLICAȚIE --`  
`# Portul intern al API-ului Fastify (Alocat în Partea 2)`  
`NUMQ_APP_PORT=6750`  
`NUMQ_APP_NODE_ENV=production`

`# -- BAZA DE DATE (Specifică 'numeriqo') --`  
`NUMQ_DB_POSTGRES_URL=postgresql://numeriqo_user:ReplaceMe@postgres_server:5432/numeriqo_db`

`# -- CHEI API PENTRU INTEGRĂRI  --`  
`NUMQ_API_ANAF_CLIENT_ID=ReplaceMeWithAnafClientID`  
`NUMQ_API_ANAF_CLIENT_SECRET=ReplaceMeWithAnafClientSecret`  
`NUMQ_API_REVOLUT_API_KEY=ReplaceMeWithRevolutAPIKey`  
`NUMQ_API_BNR_ENDPOINT_URL=https://www.bnr.ro/nbrfxrates.xml`

`# -- URL-URI SERVICII INTERNE --`  
`# Adresa serviciului de identitate (folosind portul alocat în Partea 2)`  
`NUMQ_SVC_CP_IDENTITY_URL=http://identity:6250`

#### **Șablon 4: .observability.env (Configurare Stack Observabilitate)**

Acest fișier configurează stack-ul de observabilitate în sine (Grafana, Prometheus, etc.).  
`#######################################################`  
`# INFRASTRUCTURĂ: OBSERVABILITATE (OBS)`  
`# Sursă:  (shared/observability)`  
`#######################################################`

`# -- SECRETE SERVICII --`  
`OBS_GRAFANA_ADMIN_USER=admin`  
`OBS_GRAFANA_ADMIN_PASS=ReplaceMeWithSecureGrafanaPassword`  
`OBS_PROMETHEUS_ADMIN_USER=admin`  
`OBS_PROMETHEUS_ADMIN_PASS=ReplaceMeWithSecurePrometheusPassword`

`# -- CONFIGURARE PORTURI (Din Partea 2) --`  
`# Porturile pe care serviciile stack-ului *ascultă*`  
`OBS_GRAFANA_PORT=3000`  
`OBS_PROMETHEUS_PORT=9090`  
`OBS_LOKI_PORT=3100`  
`OBS_TEMPO_PORT=3200`  
`OBS_OTEL_GRPC_PORT=4317`  
`OBS_OTEL_HTTP_PORT=4318`

## **Partea 2: Strategia Standardizată pentru Porturi și Rețele Interne**

O strategie de porturi standardizată este esențială pentru a preveni conflictele în mediile de dezvoltare și producție, pentru a simplifica configurarea proxy-ului și pentru a impune o segmentare de rețea securizată.

### **2.1. Arhitectura Rețelei Docker în Modelul Hibrid**

Planul suitei menționează "rețele Docker interne" și "rețele partajate" gestionate de orchestratorul root. Pentru a implementa o arhitectură robustă și securizată (Zero Trust networking), aceste rețele logice sunt formalizate după cum urmează:  
**Tabelul 3: Matricea Rețelelor Interne Docker**

| Nume Rețea Docker | Scop și Principiu de Securitate | Membri Cheie |
| :---- | :---- | :---- |
| net\_edge | **Rețea Public-Facing (Edge).** Singura rețea expusă la internet. | Lumea exterioară (Internet) \<-\> proxy/Traefik |
| net\_suite\_internal | **Rețea API Internă (Trusted).** Conectează proxy-ul la toate API-urile de aplicații. Niciun serviciu de date (DB, Kafka) nu se află pe această rețea. | proxy/Traefik \<-\> gateway/ \<-\> Toate API-urile (de ex. cp/identity, archify.app/api, vettify.app/api) |
| net\_backing\_services | **Rețea Securizată (Backing Services).** Rețea izolată pentru servicii de infrastructură critice. Nu este accesibilă direct de la net\_edge. | API-uri (de ex. cp/identity, numeriqo.app/api) \<-\> db/PostgreSQL, Broker/Kafka, BPM/Temporal |
| net\_observability | **Rețea de Management (Observability).** Permite stack-ului de observabilitate să "scaneze" toate celelalte servicii pentru metrici și log-uri. | shared/observability (Prometheus, Loki, OTEL) \<-\> *Toate* celelalte servicii (pe porturile lor de metrici/log) |

### **2.2. Porturi Externe și Proxy (Edge)**

Așa cum este definit în și , proxy/Traefik este singurul punct de intrare.

* **Port 80 (HTTP):** Alocat pentru traficul HTTP standard. Se va configura cu o regulă de redirectare permanentă (301) către HTTPS.  
* **Port 443 (HTTPS):** Alocat pentru traficul securizat. Terminarea TLS (cu certificate ACME/Let's Encrypt) se va realiza la acest nivel.

### **2.3. Alocarea Porturilor pentru Servicii de Bază (Backing Services)**

Pentru serviciile de infrastructură fundamentale (baze de date, brokeri, auth core), se vor utiliza porturile standard (default) din industrie. Această abordare reduce complexitatea configurării și curba de învățare. Cercetarea surselor externe confirmă aceste porturi standard.  
Tabelul 4 stabilește alocarea porturilor interne pentru aceste servicii.  
**Tabelul 4: Matricea de Alocare a Porturilor (Servicii de Bază)**

| Componentă | Tehnologie | Port Alocat (Intern) | Justificare (Sursă Externă) | Rețea Docker |
| :---- | :---- | :---- | :---- | :---- |
| Baze de Date | PostgreSQL 18 | 5432 | Portul standard industrial | net\_backing\_services |
| Broker | Apache Kafka 4.1.0 | 9092 | Portul standard pentru brokeri | net\_backing\_services |
| Auth Core | SuperTokens 11.2.0 | 3567 | Portul standard al nucleului ST | net\_backing\_services |
| BPM | Temporal TS SDK 1.13.1 | 7233 | Portul gRPC standard al Temporal Frontend | net\_backing\_services |
| Observability (UI) | Grafana | 3000 | Portul web UI standard | net\_suite\_internal |
| Observability (Data) | Prometheus | 9090 | Portul standard pentru server/scraping | net\_observability |
| Observability (Data) | Loki | 3100 | Portul standard pentru ingestie | net\_observability |
| Observability (Data) | Tempo | 3200 | Alocare standard comună (pentru a evita conflictul cu Loki) | net\_observability |
| Observability (Data) | OTEL Collector (gRPC) | 4317 | Portul IANA oficial pentru OTLP/gRPC | net\_observability |
| Observability (Data) | OTEL Collector (HTTP) | 4318 | Portul IANA oficial pentru OTLP/HTTP | net\_observability |

### **2.4. Alocarea Standardizată a Plajelor de Porturi Interne (Aplicații și Servicii)**

Strategia inițială de alocare a unui singur port per API este insuficientă. Așa cum ați subliniat, integrarea motoarelor de observabilitate și metrici (menționată în planul F0.3) necesită porturi dedicate suplimentare pentru fiecare modul (de exemplu, pentru expunerea metricilor Prometheus, endpoint-uri de telemetrie, sau servicii 'worker' separate, cum ar fi în archify.app/services/ sau cerniq.app/consumers/).  
Adoptarea unei strategii de *plaje de porturi* (ranges) este esențială. Pentru a elimina complet conflictele cu porturile serviciilor de bază (de ex. 3100 și 3200), toate aplicațiile și modulele CP vor fi mutate în intervalul 6xxx, care este liber și oferă spațiu amplu.  
Se rezervă **50 de porturi** pentru fiecare aplicație și serviciu al Control Plane. Această abordare oferă spațiul necesar pentru API-ul principal (de ex., portul xx00 sau xx50), metrici (ex., xx01 sau xx51) și rezerve viitoare ample, adaptate nevoilor de dezvoltare.  
**Tabelul 5: Matricea de Alocare a Plajelor de Porturi (API-uri Interne și Servicii)**

| Componentă | Plajă Alocată (Intern) | API Principal (Exemplu) | Utilizări (Exemple) | Rețea Docker |
| :---- | :---- | :---- | :---- | :---- |
| **Interval 6000-6099: Infrastructură (Gateway/BFF)** |  |  |  |  |
| gateway/bff | 6000-6049 | 6000 | API, Metrici, Debug | net\_suite\_internal |
| geniuserp.app/api (BFF Public) | 6050-6099 | 6050 | API, Metrici, Debug | net\_suite\_internal |
| **Interval 6100-6499: Control Plane (CP)** |  |  |  |  |
| cp/suite-shell (BFF) | 6100-6149 | 6100 | API, Metrici, Debug | net\_suite\_internal |
| cp/suite-admin (API) | 6150-6199 | 6150 | API, Metrici, Debug | net\_suite\_internal |
| cp/suite-login (API) | 6200-6249 | 6200 | API, Metrici, Debug | net\_suite\_internal |
| cp/identity (API OIDC) | 6250-6299 | 6250 | API, Metrici, Debug | net\_suite\_internal |
| cp/licensing (API) | 6300-6349 | 6300 | API, Metrici, Debug | net\_suite\_internal |
| cp/analytics-hub (API) | 6350-6399 | 6350 | API, Metrici, Debug | net\_suite\_internal |
| cp/ai-hub (API) | 6400-6449 | 6400 | API, Metrici, Debug | net\_suite\_internal |
| *Rezervat CP* | 6450-6499 |  |  |  |
| **Interval 6500-6999: Aplicații Stand-Alone (.app)** |  |  |  |  |
| archify.app/api | 6500-6549 | 6500 | API, Metrici, Workers | net\_suite\_internal |
| cerniq.app/api | 6550-6599 | 6550 | API, Metrici, Consumers | net\_suite\_internal |
| flowxify.app/api | 6600-6649 | 6600 | API, Metrici, Realtime GW | net\_suite\_internal |
| i-wms.app/api | 6650-6699 | 6650 | API, Metrici, RF Terminal | net\_suite\_internal |
| mercantiq.app/api | 6700-6749 | 6700 | API, Metrici, Engines | net\_suite\_internal |
| numeriqo.app/api | 6750-6799 | 6750 | API, Metrici, Debug | net\_suite\_internal |
| triggerra.app/api | 6800-6849 | 6800 | API, Metrici, Engines | net\_suite\_internal |
| vettify.app/api | 6850-6899 | 6850 | API, Metrici, Graph | net\_suite\_internal |
| *Rezervat aplicații viitoare* | 6900-6999 |  |  |  |

## **Partea 3: Sinergia Strategiilor și Recomandări de Implementare**

### **3.1. Conectarea Strategiilor: De la Port la Placeholder**

Cele două strategii (Configurație și Porturi) sunt complementare și interconectate. Valorile definite în Partea 2 (Strategia de Porturi) devin valorile alocate placeholder-elor definite în Partea 1 (Strategia .env).  
Docker Compose va utiliza aceste fișiere .env pentru a injecta variabilele în containere, configurând astfel porturile de ascultare și adresele serviciilor dependente.  
Tabelul 6 oferă o "Piatră de Rosetta" care demonstrează această sinergie pentru componente cheie, răspunzând direct solicitării de a arăta cum se conectează strategiile.  
**Tabelul 6: Matricea de Sinergie (.env Placeholder \-\> Valoare Port Standardizată)**

| Fișier .env Țintă | Placeholder Variabilă (Partea 1\) | Valoare Alocată (Port/Host) (Partea 2\) | Sursă Valoare |
| :---- | :---- | :---- | :---- |
| .suite.general.env | SUITE\_MQ\_KAFKA\_BROKERS | kafka:9092 | Tabelul 4 |
| .suite.general.env | SUITE\_BPM\_TEMPORAL\_HOST\_PORT | temporal:7233 | Tabelul 4 |
| .suite.general.env | SUITE\_OBS\_OTEL\_COLLECTOR\_HTTP\_URL | [http://otel-collector:3200](http://otel-collector:3200) | Tabelul 4 |
| .observability.env | OBS\_GRAFANA\_PORT | 3000 | Tabelul 4 |
| .observability.env | OBS\_PROMETHEUS\_PORT | 9090 | Tabelul 4 |
| .cp.identity.env | CP\_IDT\_APP\_PORT | 6250 | Tabelul 5 (Plaja 6250-6299) |
| .cp.identity.env | CP\_IDT\_AUTH\_SUPERTOKENS\_CONNECTION\_URI | [http://supertokens-core:3567](http://supertokens-core:3567) | Tabelul 4 |
| .archify.env | ARCHY\_APP\_PORT | 6500 | Tabelul 5 (Plaja 6500-6549) |
| .archify.env | ARCHY\_SVC\_CP\_IDENTITY\_URL | [http://identity:6250](http://identity:6250) | Tabelul 5 |
| .vettify.env | VETFY\_APP\_PORT | 6850 | Tabelul 5 (Plaja 6850-6899) |

### **3.2. Recomandări de Implementare DevSecOps (Dev vs. Producție)**

Fișierele .env sunt o componentă fundamentală a dezvoltării locale, dar reprezintă un risc de securitate semnificativ dacă sunt utilizate în producție.  
Planul suitei anticipează această problemă. Includerea fișierelor env/vault.template.hcl în structura aplicațiilor (de exemplu, archify.app/env/, cerniq.app/env/) și a unui director scripts/security/vault/ indică o intenție clară de a utiliza o soluție de management al secretelor, cum ar fi HashiCorp Vault, pentru mediile de producție.  
Strategia de implementare recomandată este, prin urmare, duală:

1. **Mediul dev (Local):**  
   * Dezvoltatorii vor utiliza fișierele .env standardizate (de exemplu, .archify.env, .vettify.env) definite în Partea 1\.  
   * Aceste fișiere sunt *strict interzise* în Git (asigurat printr-o regulă \*.env în .gitignore).  
   * Docker Compose va fi invocat folosind flag-ul \--env-file: docker compose \-f archify.app/compose/docker-compose.yml \--env-file.archify.env up  
2. **Mediile staging și prod:**  
   * **Nu** se vor utiliza fișiere .env.  
   * Pipeline-ul de CI/CD (definit în scripts/ci/) va fi responsabil pentru preluarea secretelor.  
   * Convenția de numire a variabilelor (de exemplu, ARCHY\_APP\_PORT) stabilită în Partea 1.3 devine limbajul comun. Scripturile de CI (de exemplu, scripts/security/vault/inject.ts) vor utiliza aceste nume de chei pentru a citi secretele din Vault (folosind șabloanele vault.template.hcl) și a le injecta în containerele Docker ca variabile de mediu la momentul pornirii.

Prin această abordare, convenția de numire a placeholder-elor (\<PREFIX\>\_\<CATEGORIE\>\_\<NUME\>) devine piatra de temelie care conectează dezvoltarea locală (fișiere .env) cu producția securizată (căi în Vault).

### **3.3. Guvernanță și Mentenanță**

Acest raport nu este un document static, ci un standard de guvernanță activ. Orice adăugare de noi servicii, microservicii sau aplicații stand-alone în monorepo-ul GeniusERP impune actualizarea acestui document.  
Procesul de onboarding pentru un serviciu nou (de exemplu, new-feature.app) este următorul:

1. **Partea 2 (Porturi):** Alocați un port intern unic din intervalul corespunzător (de exemplu, 6900 din Tabelul 5).  
2. **Partea 1 (Config):**  
   * Alocați un prefix unic (de exemplu, NEWF\_) și adăugați-l în Tabelul 2\.  
   * Definiți fișierul .new-feature.env (Tabelul 1).  
   * Creați șabloanele new-feature.env.example și vault.template.hcl folosind convenția de numire (de exemplu, NEWF\_APP\_PORT, NEWF\_DB\_POSTGRES\_URL).  
3. **Partea 3 (Sinergie):** Adăugați noile mapări în Tabelul 6 (de exemplu, NEWF\_APP\_PORT \-\> 6900).

Respectarea acestui proces asigură că suita GeniusERP rămâne organizată, securizată și liberă de conflicte de configurare pe măsură ce se scalează.

#### **Works cited**

1\. Loki: Getting Started \- DEV Community ([dev.to](https://dev.to/joachim8675309/loki-getting-started-n8o))
2\. How to Set Up Grafana, Loki, and Prometheus Locally with Docker Compose: Part 1 of 3 \| by Ahmad Bilal \| Medium ([medium.com](https://medium.com/@ahmadbilalch891/how-to-set-up-grafana-loki-and-prometheus-locally-with-docker-compose-part-1-of-3-62fb25e51d92))
3\. Manage authentication \| Grafana Loki documentation ([grafana.com](https://grafana.com/docs/loki/latest/operations/authentication/))
