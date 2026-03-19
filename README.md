_This project has been created as part of the 42 curriculum by vcaratti._

[ __INCEPTION__ ]

## [ Description ]

Inception is a system administration project that involves setting up a small web infrastructure using Docker.
The goal is to build and configure multiple services; NginX, WordPress ( with PHP-FPM ), and mariaDB.
Each running in its own Docker container, all setup with Docker Compose inside a virtual machine.

The infrastructure works as follows: NginX serves as proxy ( port 443 with TLS encryption ), forwarding PHP requests to WordPress via FastCGI.
WordPress processes the requests and communicates with MariaDB for data storage. All three services are connected through a Docker network, and persistent data is stored using named Docker volumes. Only NginX is exposed to the machine network.

No pre-built images are used. Each service is built from debian:bookworm.

## [ __Instructions__]

##    [ Prerequisites ]

        - A virtual machine running Debian ( Bookworm preferably )
        - Docker ( engine and compose )

##    [    Setup    ]

        Clone repo:

         git clone <repository-url> inception
         cd inception

        Create the secrets directory and files:

         mkdir secrets
         echo "your_db_password" > secrets/db_password.txt
         echo "your_db_root_password" > secrets/db_root_password.txt
         echo "your_wp_admin_password" > secrets/wp_admin_password.txt
         echo "your_wp_user_password" > secrets/wp_user_password.txt

        Create the environment file:

         srcs/.env

        Edit srcs/.env and fill in the values.
         eg:
         ```
         DOMAIN_NAME=vcaratti.42.fr
         MYSQL_DATABASE=wordpress
         MYSQL_USER=wpuser
         WP_TITLE=Inception
         WP_ADMIN_USER=wp_chief
         WP_ADMIN_EMAIL=vcaratti@student.42belgium.be
         WP_USER=wp_writer
         WP_USER_EMAIL=writer
         ```

        Make sure your /etc/hosts contains:

         127.0.0.1   <your domain name> (here: vcaratti.42.fr)


        Build and start:

         make

        ( optional ) install visual browser:

         sudo apt install -y xorg openbox firefox-esr
         startx
        `right click on blackscreen -> browser -> https://DOMAIN`


##    [ Make commands ]

        make — build and start all services
        make down — stop and remove containers
        make stop — stop containers without removing them
        make start — restart stopped containers
        make logs — view logs from all containers
        make clean — remove everything (containers, images, volumes, data)
        make re — clean rebuild from scratch



## [ __Description__ ]


##    [ Architecture ]

        The project consists of three containers connected via a Docker bridge network:

        NGINX — The Proxy. The only container exposed to the outside world (port 443).
                Handles TLS termination using a self-signed certificate and forwards PHP requests to WordPress via FastCGI on port 9000.

        WordPress + PHP-FPM — runs the WordPress application.
                              PHP-FPM listens on port 9000 for requests from NGINX and connects to MariaDB on port 3306 for database operations.

        MariaDB — The database server.
                  Stores all WordPress data (posts, users, settings). Only accessible from within the Docker network.

        Two named volumes provide persistent storage:
         /home/vcaratti/data/mariadb/
         /home/vcaratti/data/wordpress

##    [ Virtual Machines vs Docker ]

        A virtual machine emulates an entire computer with its own operating system, kernel, and hardware resources,
        each vm runs a full operating system, which makes them heavy, but fully isolated from the host system.
        Docker containers share the host's kernel and only package the application and its dependencies,
        which makes containers lightweight but with less isolation than a full virtual machine.
        In this project, the virtual machine provides the isolated environment the subject requires,
        while Docker provides efficient service separation within it.

##    [ Secrets vs Environment Variables ]

        Environment variables are passed to containers in plain text and are visible in process listings, Docker inspect output, and logs.
        They are suitable for non-sensitive configuration like database names, usernames, and domain names.
        Docker secrets are stored as files mounted at /run/secrets/ inside the container and are only accessible to services that explicitly declare them.
        They are not visible in inspect output or logs.
        In this project, passwords are stored as Docker secrets while non-sensitive configuration uses environment variables in a .env file.

##    [ Docker Network vs Host Network ]

        Host networking is simple, but costs in security. We want to isolate Docker as much as possible here, thus giving port access to the host is not wise.
        Docker bridge networking creates an isolated virtual network where containers communicate using service names as hostnames.
        Only NginX's port 443 is reachable from the host.
        All containers use the docker network "Inception".

##    [ Docker Volumes vs Bind Mounts ]

        Bind mounts map a specific host directory into a container. They depend on the exact host filesystem path and the host's directory structure.
        Docker named volumes are managed by Docker and are portable, easier to back up, and independent of the host's directory layout.
        Named volumes also have better performance on some platforms.
        Here, the named volumes use `driver_opts` to store their data at `/home/vcaratti/data/` on the host as required.



## [   __Resources__   ]

##    [  References  ]

        Docker documentation: https://docs.docker.com/
        Docker Compose documentation: https://docs.docker.com/compose/
        NGINX documentation: https://nginx.org/en/docs/
        WordPress CLI documentation: https://developer.wordpress.org/cli/commands/
        MariaDB documentation: https://mariadb.com/kb/en/documentation/
        OpenSSL documentation: https://www.openssl.org/docs/

##    [   AI Usage  ]


        Understanding concepts and debugging :
         AI was used as a learning tool to understand the TLS setup, FastCGI proxying, PHP-FPM configuration, and MariaDB initialization.
         When encountering errors during development, AI was consulted to understand error messages.
        Writing documentation:
         AI assisted in drafting this README, USER_DOC.md, and DEV_DOC.md.

        All Dockerfiles, configuration files, and scripts were written by hand. The AI was not used to generate the infrastructure code itself.
