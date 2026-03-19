# Developer Documentation

## Setting Up the Environment From Scratch

### Prerequisites

- Virtual machine running Debian Bookworm (minimal install, no desktop required)
- Docker Engine and Docker Compose plugin installed
- `sudo`, `git`, `make`, `curl` installed

### Configuration Files

1. Create the environment file:

```
cp srcs/.env.example srcs/.env
```

Edit `srcs/.env` and fill in all values (usernames, emails, domain name, site title).

2. Create the secrets directory and password files:

```
mkdir -p secrets
echo "your_password" > secrets/db_password.txt
echo "your_password" > secrets/db_root_password.txt
echo "your_password" > secrets/wp_admin_password.txt
echo "your_password" > secrets/wp_user_password.txt
```

Each file must contain only the password with no trailing newline or extra characters.

3. Ensure `/etc/hosts` contains:

```
127.0.0.1   vcaratti.42.fr
```

## Building and Launching

Build and start everything:

```
make
```

This runs three steps: creates host data directories, builds all Docker images from the Dockerfiles, and starts the containers.

Rebuild from scratch:

```
make re
```

Build without starting:

```
make build
```

## Managing Containers and Volumes

### Container Commands

| Command | Effect |
|---|---|
| `make up` | Start containers |
| `make down` | Stop and remove containers |
| `make stop` | Stop without removing |
| `make start` | Restart stopped containers |
| `make logs` | View all logs |
| `make clean` | Remove containers, images, volumes, and data |

### Inspecting a Container

Open a shell inside a running container:

```
docker exec -it mariadb /bin/bash
docker exec -it wordpress /bin/bash
docker exec -it nginx /bin/bash
```

### Volume Management

List volumes:

```
docker volume ls
```

Inspect a volume:

```
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data
```

## Data Storage and Persistence

All persistent data is stored on the host at `/home/vcaratti/data/`:

| Path | Contains | Used by |
|---|---|---|
| `/home/vcaratti/data/mariadb/` | Database files | MariaDB |
| `/home/vcaratti/data/wordpress/` | WordPress core, themes, plugins, uploads, wp-config.php | WordPress + NGINX |

These directories are mounted into the containers via Docker named volumes defined in `docker-compose.yml`.

Data persists across `make down` and `make up`. Only `make clean` deletes the data.

### How Persistence Works

The `docker-compose.yml` defines two named volumes with `driver_opts` that point to the host directories. When containers start, Docker mounts these directories at `/var/lib/mysql` (MariaDB) and `/var/www/html` (WordPress and NGINX). The init scripts in each container check if data already exists before initializing, so restarting containers does not overwrite existing data.
