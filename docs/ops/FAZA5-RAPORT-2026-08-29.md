# Raport — închidere review (metrici bază+1, restic DR, push)

**Host:** hz2.65  
**Secrete:** nicio valoare în acest fișier.

## Decizie metrici

Contractul Tabelul 5 rămâne: API = bază, metrici = bază+1. Nu amendăm documentul. `startMetricsServer` în `shared/observability` servește GET/HEAD `/metrics` pe un listener separat. Cele 15 aplicații live: `/metrics` pe bază+1 = 200; pe baza API = 404. Prometheus `geniuserp-apps` scrape-uiește baza+1. `gateway` și `geniuserp-app` rămân down (lipsă din repo).

## Restic DR

Scriptul `/usr/local/sbin/restic-hz2-backup.sh` include definiția platformei: `/opt/platform.env`, `/opt/{openbao,temporal,supertokens,kafka,observability,traefik}`, `openbao-unseal.service`, plus volumele de pe `/mnt`. **Parola restic trebuie copiată off-host de operator** (password manager / telefon). Nu e o acțiune pe care host-ul o poate închide singur.

## Git

Commitul de metrici + runbook e local, pe `chore/stack-upgrade-2026-08-28`. Push/PR de pe stația cu acces GitHub (`gh` lipsește pe hz2.65; origin HTTPS fără credențiale).
