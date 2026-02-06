## Glance — Home-lab

A place to keep my home-lab configs and helper scripts so I can
rebuild or recover services quickly if I ever mess up the system. :)

Purpose
- Store docker-compose manifests, service configs, and small helper
	scripts for my home-lab.

Repository layout
- `glance_config/`: service configuration files (YAMLs, etc.)
- `glance_assets/`: static assets (user.css, UI files)
- `docker-compose.yml`: main compose file for local development / deployment
- `git-push.sh`: convenience script for pushing changes (see script for details)

Quick start
Prerequisites: docker (and `docker-compose` or a compatible compose tool).

To start services:

```bash
docker-compose up -d
```

To stop services:

```bash
docker-compose down
```

Backup & restore
- Keep any secrets and credentials out of this repo; store them in a
	secure vault or outside the repo.
- To backup: copy the configs and any volumes you need from the host.

Notes
- This repo is intended as a lightweight, versioned snapshot of my
	home-lab configuration. Tweak compose files and configs here, test,
	then deploy to the host.
