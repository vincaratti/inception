*This project has been created as part of the 42 curriculum by vcaratti.*

# Inception

## Description

Inception is a system administration project that involves setting up a small web infrastructure using Docker. The goal is to build and configure multiple services — NGINX, WordPress with PHP-FPM, and MariaDB — each running in its own Docker container, orchestrated with Docker Compose inside a virtual machine.

The infrastructure works as follows: NGINX serves as the sole entry point on port 443 with TLS encryption, forwarding PHP requests to WordPress via FastCGI. WordPress processes the requests using PHP-FPM and communicates with MariaDB for data storage. All three services are connected through a Docker network, and persistent data is stored using named Docker volumes.

No pre-built images are used. Each service is built from a custom Dockerfile based on Debian Bookworm.

## Instructions

### Prerequisites

- A virtual machine running Debian Bookworm
- Docker Engine and Docker Compose installed
- Git

### Setup

1. Clone the repository:

```
git clone <repository-url> ~/inception
cd ~/inception
```

2. Create the secrets directory and files:

```
mkdir -p secrets
echo "your_db_password" > secrets/db_password.txt
echo "your_db_root_password" > secrets/db_root_password.txt
echo "your_wp_admin_password" > secrets/wp_admin_password.txt
echo "your_wp_user_password" > secrets/wp_user_password.txt
```

3. Create the environment file:

```
cp srcs/.env.example srcs/.env
```

Edit `srcs/.env` and fill in the values.

4. Make sure your `/etc/hosts` contains:

```
127.0.0.1   vcaratti.42.fr
```

5. Build and start:

```
make
```

6. Access the site at `https://vcaratti.42.fr`.

### Available Make commands

- `make` — build and start all services
- `make down` — stop and remove containers
- `make stop` — stop containers without removing them
- `make start` — restart stopped containers
- `make logs` — view logs from all containers
- `make clean` — remove everything (containers, images, volumes, data)
- `make re` — clean rebuild from scratch

## Project Description

### Architecture

The project consists of three containers connected via a Docker bridge network:

- **NGINX** — the only container exposed to the outside world (port 443). Handles TLS termination using a self-signed certificate and forwards PHP requests to WordPress via FastCGI on port 9000.
- **WordPress + PHP-FPM** — runs the WordPress application. PHP-FPM listens on port 9000 for requests from NGINX and connects to MariaDB on port 3306 for database operations.
- **MariaDB** — the database server. Stores all WordPress data (posts, users, settings). Only accessible from within the Docker network.

Two named volumes provide persistent storage: one for the WordPress files and one for the MariaDB database, both mapped to `/home/vcaratti/data/` on the host.

### Virtual Machines vs Docker

A virtual machine emulates an entire computer with its own operating system, kernel, and hardware resources. Each VM runs a full OS, which makes them heavy (gigabytes of disk, minutes to boot) but fully isolated. Docker containers share the host's kernel and only package the application and its dependencies. This makes containers lightweight (megabytes, seconds to start) but with less isolation than a full VM. In this project, Docker runs inside a VM — the VM provides the isolated environment the subject requires, while Docker provides efficient service separation within it.

### Secrets vs Environment Variables

Environment variables are passed to containers in plain text and are visible in process listings, Docker inspect output, and logs. They are suitable for non-sensitive configuration like database names, usernames, and domain names. Docker secrets are stored as files mounted at `/run/secrets/` inside the container and are only accessible to services that explicitly declare them. They are not visible in inspect output or logs. In this project, passwords are stored as Docker secrets while non-sensitive configuration uses environment variables in a `.env` file.

### Docker Network vs Host Network

Host networking (`network: host`) removes network isolation — the container shares the host's network stack directly. Any port the container opens is immediately available on the host. This is simple but insecure and forbidden by the subject. Docker bridge networking creates an isolated virtual network where containers communicate using service names as hostnames. Only explicitly published ports (like NGINX's 443) are reachable from outside. In this project, all containers use a custom bridge network called `inception`, and only NGINX exposes a port to the host.

### Docker Volumes vs Bind Mounts

Bind mounts map a specific host directory into a container. They depend on the exact host filesystem path and the host's directory structure. Docker named volumes are managed by Docker and are portable, easier to back up, and independent of the host's directory layout. Named volumes also have better performance on some platforms. The subject requires named volumes, not bind mounts. In this project, the named volumes use `driver_opts` to store their data at `/home/vcaratti/data/` on the host as required.

## Resources

### References

- Docker documentation: https://docs.docker.com/
- Docker Compose documentation: https://docs.docker.com/compose/
- NGINX documentation: https://nginx.org/en/docs/
- WordPress CLI documentation: https://developer.wordpress.org/cli/commands/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- OpenSSL documentation: https://www.openssl.org/docs/
- 42 Inception subject PDF

### AI Usage

AI (Claude by Anthropic) was used for two purposes during this project:

- **Understanding concepts and debugging**: AI was used as a learning tool to understand Docker concepts (containers, volumes, networks, secrets), NGINX configuration (TLS setup, FastCGI proxying), PHP-FPM configuration, and MariaDB initialization. When encountering errors during development, AI was consulted to understand error messages and find solutions.
- **Writing documentation**: AI assisted in drafting this README, USER_DOC.md, and DEV_DOC.md.

All Dockerfiles, configuration files, and scripts were written by hand. The AI was not used to generate the infrastructure code itself.
