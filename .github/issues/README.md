# Issues Locale - Sistem de Publicare Automată

Acest folder conține issues care vor fi publicate automat pe GitHub.

## Cum să creezi un issue local:

### 1. Pentru Sub-faze (Epic Trackers):
Creează un fișier `sub-faza-{cod}.yml` în acest folder:

```yaml
title: "F0.1 - Inițializare Infrastructură"
body: |
  ## Obiectiv
  Configurare bază pentru dezvoltarea GeniusERP Suite

  ## Criterii de Acceptare
  - Repository GitHub creat
  - Workflow-uri CI/CD configurate
  - Structura monorepo stabilită
labels: ["epic-tracker", "faza-0"]
```

### 2. Pentru Task-uri:
Creează un fișier `task-{cod}.yml` în acest folder:

```yaml
title: "F0.1.1 - Setup Repository GitHub"
body: |
  ## Descriere
  Creare repository GeniusERP_Suite pe GitHub cu structura de bază

  ## Livrabile
  - Repository creat și configurat
  - README.md adăugat
  - .gitignore configurat
labels: ["task", "infrastructure"]
assignees: ["neacisu"]
```

## Cum să publici issues:

### Opțiunea 1: Script automat
```bash
npm run publish:issues
# sau
pnpm publish:issues
```

### Opțiunea 2: Manual cu GitHub CLI
```bash
gh issue create --template task-F0.1.1.yml
```

### Opțiunea 3: Workflow GitHub Actions
Issues se vor publica automat când faci push la branch-ul dev.

## Structura fișierelor:
- `title`: Titlul issue-ului
- `body`: Conținutul issue-ului (în format Markdown)
- `labels`: Lista de etichete (opțional)
- `assignees`: Lista de asignați (opțional)
