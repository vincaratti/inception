# Inception — VM & Environment Setup Guide

*Everything you need to do before touching the inception/ project directory.*

---

## 1. Creating the Virtual Machine

### 1.1 Choose your hypervisor

At 42, use VirtualBox (installed on school Macs) or UTM if you are on Apple Silicon. If working from home, download VirtualBox from virtualbox.org.

### 1.2 Download a Debian ISO

Go to https://www.debian.org/download and grab the **netinst** (minimal network install) ISO for the penultimate stable release. As of early 2026, the penultimate stable is **Debian 12 Bookworm** (Debian 13 Trixie being the latest). Verify what your school considers "penultimate" at the time of your evaluation — this matters because your Dockerfiles must use the same base.

### 1.3 Create the VM in VirtualBox

Open VirtualBox and click New. Use these settings:

- Name: inception (or anything you like)
- Type: Linux
- Version: Debian (64-bit)
- Memory: 2048 MB minimum (4096 MB recommended)
- CPU: 2 cores
- Hard disk: Create a virtual hard disk now, VDI format, dynamically allocated, 20 GB

### 1.4 Attach the ISO

Select your VM, go to Settings > Storage, click the empty optical drive, and choose the Debian ISO you downloaded. Make sure the boot order in Settings > System has Optical before Hard Disk.

### 1.5 Network configuration

In Settings > Network, Adapter 1 should be enabled. You have two main options:

- **Bridged Adapter**: The VM gets its own IP on your local network. Simplest option if available.
- **NAT with port forwarding**: The VM shares the host's IP. You must add a port forwarding rule: host port 443 → guest port 443 (protocol TCP). This is needed so you can access the NGINX container from the VM's browser.

For working at school, Bridged Adapter is usually easiest. For working from home, either works.

---

## 2. Installing Debian

Start the VM. It will boot from the ISO.

### 2.1 Installer choices

- Select **Install** (not Graphical Install — the text installer is lighter and faster).
- Language: English
- Location: your country
- Keyboard: your layout
- Hostname: pick anything (e.g., `inception`)
- Domain name: leave blank
- Root password: set a strong password and remember it
- Full name / username / password: create your user account

### 2.2 Disk partitioning

- Choose **Guided - use entire disk**
- Select the virtual hard disk
- Choose **All files in one partition** (simplest option)
- Confirm and write changes

### 2.3 Package manager

- Choose a mirror close to you
- Leave HTTP proxy blank (unless your school network requires one)

### 2.4 Software selection

This is important. When you reach the **Software selection** screen:

- **Uncheck** Debian desktop environment and all desktop options
- **Uncheck** GNOME / KDE / etc.
- **Check** SSH server
- **Check** standard system utilities
- Uncheck everything else

You do not need a graphical environment. It wastes resources and you will do everything from the terminal.

### 2.5 GRUB boot loader

- When asked to install the GRUB boot loader, say **Yes**
- Select `/dev/sda` as the device for installation
- Without GRUB, the VM will not boot after installation

### 2.6 Finish installation

Remove the ISO (VirtualBox may do this automatically) and reboot. You should see a login prompt. Log in with your username and password.

---

## 3. Post-Installation System Configuration

### 3.1 Become root and install essential packages

```
su -
apt update && apt upgrade -y
apt install -y sudo vim curl git ca-certificates gnupg lsb-release apt-transport-https make
```

`sudo` is needed so you don't have to switch to root for every command. `vim` (or `nano` if you prefer) for editing. `curl`, `ca-certificates`, `gnupg`, `lsb-release`, and `apt-transport-https` are prerequisites for installing Docker. `git` for version control. `make` for your Makefile.

### 3.2 Add your user to the sudo group

Still as root:

```
usermod -aG sudo <your_username>
```

Log out completely (type `exit` twice — once to leave root, once to log out) and log back in. Verify with:

```
sudo whoami
```

It should print `root`.

### 3.3 (Optional) Set up SSH access

If you want to work from your host terminal instead of the VirtualBox window (much more comfortable for copy-pasting), set up SSH access.

If using NAT, add a port forwarding rule: host port 4242 → guest port 22 (TCP). Then from your host:

```
ssh -p 4242 <your_username>@localhost
```

If using Bridged Adapter, find the VM's IP with `ip a` inside the VM, then from your host:

```
ssh <your_username>@<vm_ip>
```

---

## 4. Configure the Domain Name

The subject requires `<login>.42.fr` to point to your local IP.

```
sudo vim /etc/hosts
```

Add this line:

```
127.0.0.1   <login>.42.fr
```

Replace `<login>` with your actual 42 login. Save and verify:

```
ping -c 2 <login>.42.fr
```

You should see replies from 127.0.0.1.

---

## 5. Install Docker Engine

Do NOT install Docker from Debian's default apt repos — that version is outdated. Use Docker's official repository.

### 5.1 Remove any old Docker packages

```
sudo apt remove -y docker docker-engine docker.io containerd runc
```

This might say nothing was installed. That's fine.

### 5.2 Add Docker's official GPG key and repository

```
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 5.3 Install Docker Engine and Compose

```
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

This installs Docker Engine, the CLI, containerd, and Docker Compose v5 (the modern `docker compose` plugin).

### 5.4 Let your user run Docker without sudo

```
sudo usermod -aG docker <your_username>
```

Log out and back in for this to take effect. This is mandatory — without it, every docker command needs sudo.

---

## 6. Verify the Installation

Run these commands one by one to confirm everything works:

```
docker --version
```

Should print something like `Docker version 27.x.x` or higher.

```
docker compose version
```

Should print `Docker Compose version v5.x.x`.

```
docker run --rm hello-world
```

Should print "Hello from Docker!" and exit cleanly.

```
docker run --rm debian:bookworm echo "Debian works"
```

Should print "Debian works". This also confirms you can pull the base image your Dockerfiles will use.

---

## 7. Create the Host Data Directories

The subject requires volumes to store data at `/home/<login>/data/` on the host machine.

```
mkdir -p /home/<your_username>/data/mariadb
mkdir -p /home/<your_username>/data/wordpress
```

These directories must exist before Docker Compose creates the named volumes that map to them.

---

## 8. Prepare Your Git Repository

### 8.1 Initialize the repo

```
mkdir -p ~/inception
cd ~/inception
git init
```

### 8.2 Create a .gitignore

```
vim .gitignore
```

Contents:

```
secrets/
srcs/.env
data/
*.swp
.DS_Store
```

This ensures passwords, environment variables with secrets, database data, and editor temp files never end up in your repo.

### 8.3 Create secret template files

```
mkdir -p secrets
echo "REPLACE_WITH_DB_PASSWORD" > secrets/db_password.txt
echo "REPLACE_WITH_DB_ROOT_PASSWORD" > secrets/db_root_password.txt
```

Then create copies that ARE committed, so you remember the format:

```
cp srcs/.env srcs/.env.example   (create this after setting up .env)
```

### 8.4 First commit

```
git add .
git commit -m "Initial project structure"
git remote add origin <your-repo-url>
git push -u origin main
```

---

## 9. Rebuilding on a Fresh Machine

If your storage gets wiped, here is the exact sequence to get back to a working state:

1. Install Debian in a new VM (repeat sections 1–2)
2. Run post-install setup (repeat section 3)
3. Configure /etc/hosts (repeat section 4)
4. Install Docker (repeat section 5)
5. Create data directories (repeat section 7)
6. Clone your repo:

```
git clone <your-repo-url> ~/inception
cd ~/inception
```

7. Recreate your secrets and .env:

```
vim secrets/db_password.txt
vim secrets/db_root_password.txt
vim srcs/.env
```

8. Build and start:

```
make
```

Everything rebuilds from your Dockerfiles automatically. The only manual steps are the VM setup, Docker installation, and filling in your secrets.

---

## 10. Useful Commands Reference

Check if Docker daemon is running:

```
sudo systemctl status docker
```

Start Docker if it's not running:

```
sudo systemctl start docker
sudo systemctl enable docker
```

See all running containers:

```
docker ps
```

See all containers including stopped ones:

```
docker ps -a
```

See all images:

```
docker images
```

See all volumes:

```
docker volume ls
```

See all networks:

```
docker network ls
```

Remove everything Docker has built (nuclear option):

```
docker compose -f ~/inception/srcs/docker-compose.yml down -v --rmi all
docker system prune -a --volumes
```

Check disk usage by Docker:

```
docker system df
```

Follow logs of a specific container:

```
docker logs -f <container_name>
```

Open a shell inside a running container:

```
docker exec -it <container_name> /bin/bash
```
