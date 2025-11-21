# OpenBao Dynamic Database Roles

This folder hosts the SQL templates folosite de Database Secrets Engine pentru a crea utilizatori efemeri specifici fiecărei aplicații. Fiecare fișier `*_runtime.sql` conține declarații `CREATE ROLE` + `GRANT` pentru schema `public` din baza de date a aplicației respective.

## Cum adaugi un nou rol

1. Creează un fișier nou `database/roles/<slug>_runtime.sql` plecând de la exemplele existente.
2. Adaugă intrarea corespunzătoare în `database/roles/roles.json` (nume rol, DB, TTL, fișier SQL, extensii Postgres dacă sunt necesare — ex. `"extensions": ["vector"]`).
3. Rulează `scripts/security/openbao-sync-app-roles.sh` pentru a recrea conexiunea OpenBao + rolul.
4. Validează cu `bao read database/creds/<role-name>` că primești utilizator/TTL corect.

## Fișiere generate

- **SQL templates**: consumate de `bao write database/roles/<role>` cu sintaxa `creation_statements=@file.sql`.
- **roles.json**: manifest folosit de scriptul de sincronizare pentru a ști ce baze și TTL-uri trebuie configurate.

> Notă: SQL-ul acordă doar privilegii de runtime (SELECT/INSERT/UPDATE/DELETE + acces la sequences/functions). Migrațiile și operațiile cu privilegii ridicate trebuie să continue să folosească conturi cu roluri dedicate (DevOps / DBA).
