# User Documentation

## Services

This stack provides three services:

- **NGINX** — web server that handles HTTPS connections on port 443
- **WordPress** — the website and content management system
- **MariaDB** — the database that stores all WordPress content

## Starting and Stopping

Start the project:

```
make
```

Stop the project (data is preserved):

```
make down
```

Restart after stopping:

```
make
```

Full reset (deletes all data and rebuilds from scratch):

```
make re
```

## Accessing the Website

Open a browser and go to:

```
https://vcaratti.42.fr
```

Accept the self-signed certificate warning when prompted.

## Accessing the Administration Panel

Go to:

```
https://vcaratti.42.fr/wp-admin
```

Log in with the administrator credentials (see below).

From the admin panel you can create posts, manage users, install themes, and configure the site.

## Credentials

Credentials are stored in two places:

- **Usernames and non-sensitive config**: `srcs/.env`
- **Passwords**: `secrets/` directory (one password per file)

The secret files are:

| File | Contains |
|---|---|
| `secrets/db_root_password.txt` | MariaDB root password |
| `secrets/db_password.txt` | MariaDB application user password |
| `secrets/wp_admin_password.txt` | WordPress admin login password |
| `secrets/wp_user_password.txt` | WordPress regular user login password |

To view a password:

```
cat secrets/wp_admin_password.txt
```

To change a password, edit the corresponding file and run `make re` to rebuild.

## Checking That Services Are Running

Check all containers:

```
docker compose -f srcs/docker-compose.yml ps
```

All three (mariadb, wordpress, nginx) should show status `Up`.

Check individual service logs:

```
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs nginx
```

Quick test that the site responds:

```
curl -k https://vcaratti.42.fr
```

This should return HTML content.
