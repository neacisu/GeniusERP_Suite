# Strategie de Implementare: Faza F0.6 - Bootstrap & Inițializare Mediu (v2.0)

## 1. Sinopsis Executiv

Această strategie definește tranziția de la infrastructura statică la un ecosistem dinamic. Obiectivul principal este eliminarea sindromului "it works on my machine" prin standardizarea strictă a procesului de inițializare.
Schimbare Arhitecturală Majoră față de v1:
Se elimină logica hibridă (detectare localhost vs container). Toate scripturile de bootstrap vor rula EXCLUSIV în interiorul rețelei Docker, folosind un container efemer bootstrap-runner. Aceasta garantează că DNS-ul intern (postgres_identity, openbao, kafka) este întotdeauna rezolvat corect, eliminând complexitatea mapării porturilor.

## 2. Arhitectura Tehnică a Soluției

### 2.1. Containerul "Bootstrap Runner"

În loc să rulăm scripturi Node.js direct pe mașina host (care necesită .env local, Node versiunea X, porturi expuse), vom defini un serviciu utilitar în docker-compose.backing-services.yml:

```yml
services:
  bootstrap-runner:
    image: node:20-alpine
    profiles: ["tools"] # Nu pornește automat cu 'up'
    volumes:
      - ./:/app
    working_dir: /app
    depends_on:
      - openbao
      - postgres_identity
      # ... alte dependențe
    networks:
      - net_backing_services
    entrypoint: ["/app/scripts/bootstrap/entrypoint.sh"]
```

Comanda pnpm bootstrap de pe host va fi un simplu wrapper peste:
`docker compose run --rm bootstrap-runner pnpm tsx scripts/bootstrap/main.ts`

### 2.2. Strategia "Wait-For-It" (Orchestrare)

Dependențele nu pornesc instantaneu. Scriptul de bootstrap va implementa o logică strictă de așteptare la nivel de rețea înainte de execuția codului logic:

- Nivel TCP: Verificare dacă porturile 5432 (Postgres), 8200 (OpenBao), 9092 (Kafka) sunt deschise. Inchiderea proceselor existente pe aceste porturi. Curatarea lor si initializarea noilor servicii doar dupa ce porturile au fost deschise si curatate.
- Nivel Aplicație (Healthcheck):
- Postgres: pg_isready
- OpenBao: /v1/sys/health (verifică dacă este unsealed)
- Kafka: Verificare metadata brokeri.

### 2.3. Fluxul de Execuție (Pipeline)

- Securitate (Host): Generare .env criptografic din .env.example (pe host, înainte de container).
- Inițializare Infra (Container):

     > 1. Unseal OpenBao (dacă e necesar).
     > 2. Creare Bucket-uri MinIO.
     > 3. Creare Topic-uri Kafka + Schema Registry.

- Migrări Baze de Date (Drizzle): Rulare secvențială pentru fiecare schemă (Identity -> Nomenclatoare -> Business).
- Seed Date Sistem (Imuabile): Roluri, Permisiuni, Plan Conturi, Țări/Județe.
- Metoda: Idempotent Upsert (Dacă există, nu face nimic sau actualizează).
- Seed Date Demo (Opțional): Generare date sintetice (FakerJS) sau restaurare Snapshot.

## 3. Standarde de Date (Data Governance)

### 3.1. Clasificarea Datelor

Tip Date
Descriere
Strategie Persistență
Sursa
System Seed
Critice funcționării (ex: Roluri, TVA). Nu se modifică în UI.
Mandatory la fiecare deploy. Upsert.
Cod sursă (JSON/TS)
Nomenclatoare
Date de referință (ex: Județe, CAEN).
Mandatory. Upsert lent.
Fișiere CSV/SQL externe
Demo Data
Date de test (Useri, Facturi).
Optional (--seed-demo). Resetabil.
FakerJS factories

### 3.2. Integritate Referențială Distribuită

Deoarece avem baze de date separate (Identity DB, Numeriqo DB), seed-ul trebuie să respecte ordinea:

- Identity: Creare Useri & Organizații -> Se obțin UUID-urile.
- Vettify: Creare Parteneri -> Se leagă de OrgID.
- Numeriqo: Creare Facturi -> Se leagă de PartnerID (Vettify) și UserID (Identity).

## 4. Specificații Tehnice pentru Task-uri

Stack Tehnologic
Runtime: Node.js (via Docker)
Limbaj: TypeScript (tsx pentru execuție rapidă fără compilare).
ORM: Drizzle ORM (pentru type-safety în seed).
CLI: Commander.js (pentru argumente: --reset, --verbose).
Logging: Pino (formatat JSON pentru logs, pretty-print pentru consolă).
Structura Directorului scripts/bootstrap

```text
scripts/bootstrap/
├── configs/            # Configurații statice (JSON)
├── core/               # Logica de bază (DB Client, Waiters)
├── seeds/              # Logica de business
│   ├── system/         # Date imuabile (roles.ts, caen.ts)
│   └── demo/           # Faker factories (users.ts, invoices.ts)
├── utils/              # Helper functions (crypto, logger)
└── main.ts             # Entry point
```

## 5. Lista Completă de Task-uri F0.6.x (Format JSON)

Acest fișier JSON este pregătit pentru importul în sistemul de Project Management (Jira/Github Projects).

[
  {
    "phase": "F0.6",
    "title": "Bootstrap Infrastructure & Environment Initialization",
    "description": "Implementarea ecosistemului complet de inițializare GeniusERP folosind strategia 'Container-First' pentru reproductibilitate și securitate Zero-Trust.",
    "tasks": [
      {
        "id": "F0.6.1",
        "title": "Infra: Setup Bootstrap Runner Container",
        "description": "Definirea serviciului `bootstrap-runner` în `docker-compose.backing-services.yml`. Configurare Dockerfile minim bazat pe Node.js care are acces la rețeaua `net_backing_services`.",
        "type": "DevOps",
        "priority": "Critical",
        "dependencies": []
      },
      {
        "id": "F0.6.2",
        "title": "CLI: Bootstrap Entrypoint Script",
        "description": "Crearea `scripts/bootstrap/main.ts` folosind Commander.js. Implementarea logicii de argumente CLI (`--clean`, `--seed-demo`, `--force`).",
        "type": "Backend",
        "priority": "High",
        "dependencies": ["F0.6.1"]
      },
      {
        "id": "F0.6.3",
        "title": "Security: Host-Level Secret Generator",
        "description": "Script Python/Bash care rulează pe host (pre-docker), scanează `.env.example`, generează chei High-Entropy și creează fișierele `.env` necesare pentru `docker compose up`.",
        "type": "Security",
        "priority": "Critical",
        "dependencies": []
      },
      {
        "id": "F0.6.4",
        "title": "Core: Service Wait & Healthcheck Logic",
        "description": "Implementarea modulului `Waiter` care verifică disponibilitatea Postgres, OpenBao și Kafka folosind poll pe porturi și healthcheck endpoints înainte de a continua execuția.",
        "type": "Backend",
        "priority": "High",
        "dependencies": ["F0.6.2"]
      },
      {
        "id": "F0.6.5",
        "title": "Infra: OpenBao Auto-Configurator",
        "description": "Script care rulează în container, verifică starea OpenBao, execută unseal (folosind chei injectate sau salvate local) și configurează engine-urile KV/Transit.",
        "type": "DevOps",
        "priority": "Critical",
        "dependencies": ["F0.6.4"]
      },
      {
        "id": "F0.6.6",
        "title": "DB: Centralized Drizzle Migrator",
        "description": "Utilitar care iterează prin toate schemele Drizzle din `libs/` și aplicații, rulând migrările SQL în ordinea dependențelor (ex: Shared -> Identity -> Business).",
        "type": "Backend",
        "priority": "High",
        "dependencies": ["F0.6.4"]
      },
      {
        "id": "F0.6.7",
        "title": "Seed System: Identity (RBAC)",
        "description": "Popularea tabelelor `roles` și `permissions` în Identity DB. Asigurarea existenței rolurilor `SuperAdmin`, `TenantAdmin`, `User`.",
        "type": "Backend",
        "priority": "High",
        "dependencies": ["F0.6.6"]
      },
      {
        "id": "F0.6.8",
        "title": "Seed System: Identity (SuperAdmin)",
        "description": "Crearea contului de SuperAdmin. Dacă există deja, se resetează parola la valoarea din secretele generate.",
        "type": "Backend",
        "priority": "High",
        "dependencies": ["F0.6.7"]
      },
      {
        "id": "F0.6.9",
        "title": "Seed System: Nomenclatoare Geografice (Vettify)",
        "description": "Import optimizat (Batch Insert) pentru Județe (SIRUTA) și Localități. Trebuie să suporte rulări repetate (Upsert).",
        "type": "Backend",
        "priority": "Medium",
        "dependencies": ["F0.6.6"]
      },
      {
        "id": "F0.6.10",
        "title": "Seed System: Plan Conturi & Fiscalitate (Numeriqo)",
        "description": "Popularea Planului de Conturi General (Clasa 1-9) și a cotelor TVA. Esențial pentru funcționarea modulului contabil.",
        "type": "Backend",
        "priority": "High",
        "dependencies": ["F0.6.6"]
      },
      {
        "id": "F0.6.11",
        "title": "Infra: Kafka Topics Init",
        "description": "Script care folosește `kafkajs` admin client pentru a crea topic-urile necesare (ex: `user.events`, `invoice.events`) cu partițiile corecte.",
        "type": "Backend",
        "priority": "Medium",
        "dependencies": ["F0.6.4"]
      },
      {
        "id": "F0.6.12",
        "title": "Infra: MinIO Buckets Init",
        "description": "Inițializarea bucket-urilor S3 (`archify-storage`, `public-assets`) și setarea politicilor de acces (public vs private).",
        "type": "Backend",
        "priority": "Medium",
        "dependencies": ["F0.6.4"]
      },
      {
        "id": "F0.6.13",
        "title": "Demo Data: Factory Engine",
        "description": "Implementarea unui motor de generare date folosind FakerJS care respectă constrângerile de chei străine între module.",
        "type": "Backend",
        "priority": "Low",
        "dependencies": ["F0.6.6"]
      },
      {
        "id": "F0.6.14",
        "title": "Demo Data: Tenants & Organizations",
        "description": "Generarea a 3 organizații demo cu ierarhii complete de useri (CEO, Manager, Angajat) pentru testare UI.",
        "type": "Backend",
        "priority": "Low",
        "dependencies": ["F0.6.13"]
      },
      {
        "id": "F0.6.15",
        "title": "Demo Data: Commercial Flows (Mercantiq/I-WMS)",
        "description": "Generare produse, stocuri, și comenzi de test. Asigurarea fluxului complet: Comandă -> Stoc -> Factură.",
        "type": "Backend",
        "priority": "Low",
        "dependencies": ["F0.6.14"]
      },
      {
        "id": "F0.6.16",
        "title": "Tooling: Nuke Script (Reset)",
        "description": "Script periculos (`pnpm nuke`) care oprește containerele și șterge volumele docker pentru a permite un bootstrap curat.",
        "type": "DevOps",
        "priority": "Medium",
        "dependencies": ["F0.6.1"]
      },
      {
        "id": "F0.6.17",
        "title": "Docs: Ghid de Utilizare Bootstrap",
        "description": "Documentarea comenzilor în `CONTRIBUTING.md`. Explicarea flag-urilor și a modului de depanare în caz de eșec.",
        "type": "Documentation",
        "priority": "Medium",
        "dependencies": ["F0.6.2"]
      },
      {
        "id": "F0.6.18",
        "title": "CI: Github Actions Integration",
        "description": "Configurarea pipeline-ului CI pentru a rula `pnpm bootstrap --seed-system` pe mediul de testare înainte de a rula suita de teste E2E.",
        "type": "DevOps",
        "priority": "High",
        "dependencies": ["F0.6.16"]
      }
    ]
  }
]
