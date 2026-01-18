## Oracle Cloud – Reusable Docker Server Setup

This repository documents a reproducible, disposable, and Docker-first setup for running multiple applications ( websites, APIs, experiments) on Oracle Cloud.

The philosophy is simple:
- Treat the VM as disposable. Treat setup as code. Treat data as sacred.

If your Oracle instance is suspended (Only for Free tier) or deleted, you should be able to rebuild everything in ~30–45 minutes.

### 🎯 Goals
	•	Run multiple services on a single Oracle instance
	•	Use Docker for isolation and portability
	•	Make the setup reusable on any VPS or local machine
	•	Minimize downtime if Oracle suspends the instance (Only for Free tier)
	•	Keep documentation clean and copy-paste friendly

### 🧠 Core Strategy (One Sentence)
- All infrastructure setup = scripts
- All app configs = Git
- All data = backups outside the VM

### 🧠 Architecture Overview 
Oracle Cloud VM (Ubuntu 22.04, Free Tier), Mostly same of any Oracle VPS.
```
 ├── Docker
 │   ├── Reverse Proxy (Traefik)
 │   ├── Websites (Node / Static)
 │   ├── APIs (Python / FastAPI)
 │   ├── Lite LLM for experiments

•	One VM
•	Many containers
•	One public IP
•	Multiple domains/subdomains
```
### 🔐 Firewall Rules
Allowed ports:
	•	22 → SSH
	•	80 → HTTP
	•	443 → HTTPS

All other ports remain blocked.

### Step 1: Create Oracle Cloud Instance
We will use Free Tier for this purpose but process is similar for any tier.

- Follow detailed instructions from `oracle-cloud-vps-instance-setup.md`, Click [here](oracle-cloud-vps-instance-setup.md) to jump right in.
- Once instance is RUNNING, note the Public IP.

### Step 2: Clone repository and Run predefined scripts
- SSH using private key: `ssh -i your-key.key ubuntu@<PUBLIC_IP>`
- `cd ~/apps/scripts`
- Clone repository: `git clone https://github.com/avighub/oracle-cloud-instance-setup.git`
- Go to bootstrap scripts dir: `cd ~/apps/scripts/oracle-cloud-instance-setup/infra/bootstrap`
- Make the script executable: `chmod +x *.sh`
- Update `ACME_EMAIL` with your valid email in `05-traefik.sh` file
  - Run command to update: `nano 05-traefik.sh`
- Run `./bootstrap.sh`
  - It will install basic tools, Docker, Configure Firewall, Create SWAP, setup reverse proxy (Traefik) and TLS certificate (let's encrypt)
- Restart all services if prompted by Ubuntu
- Once it is completed run `newgrp docker`, to avoid permission error from docker

### Setting up a whoami Test Site
#### Option 1 : If you don't have a domain at this point
- Run the script to setup whoami test site to access via public ip
  - `cd ~/apps/scripts/infra/bootstrap`
  - `./whoami-test-site-without-domain.sh`
  - Watch Traefik logs (important): `docker logs -f traefik`
    - This should not return any error, if it does, then it would need attention
  - Note: Terminate the docker container when testing is done, to save resources. `docker compose down`
- Test it
  - via curl: `curl -I http://<PUBLIC_IP>`, This should display the whoami test site
  - via nslookup
    - `nslookup <domain-name>`: This should return public address

#### Option 2: If you have a domain ready to setup
This will enable HTTPS via Let’s Encrypt
- Add below DNS records in Zone Editor for your respective domain provider
  - Type: A, Name: @ , Value: <YOUR_PUBLIC_IP_FROM_ORACLE_VPS>
  - Type: A, Name: www , Value: <YOUR_PUBLIC_IP_FROM_ORACLE_VPS>
  
- Run the script to setup whoami test site to map with Domain  
  - `cd ~/apps/scripts/oracle-cloud-instance-setup/infra/bootstrap`
  - Make sure to update `whoami-test-site-with-domain.sh` with your domain name for variable `DOMAIN`
  - Run: `./whoami-test-site-with-domain.sh`
  - Watch Traefik logs (important): `docker logs -f traefik`
    - This should not return any error, if it does, then it would need attention
  - Note: Terminate the docker container when testing is done, to save resources. `docker compose down`
- Test it
  - via curl: `curl -I https://<domain-name>`, This should display the whoami test site
  - via nslookup
    - `nslookup <domain-name>`: This should return public address

##### DNS config to Add subdomain 
- Add below DNS records in Zone Editor for your respective domain provider
  - Type: A, Name: subdomain-name-here, Value: <YOUR_PUBLIC_IP_FROM_ORACLE_VPS>

