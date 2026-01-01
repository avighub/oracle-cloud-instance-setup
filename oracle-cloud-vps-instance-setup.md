# Oracle Cloud VPS Instance Setup

This file outlines a minimal, repeatable setup for an Oracle Free Cloud VPS and Docker setup.

### Launch an Oracle Free Tier Compute instance:
- Console: Compute → Instances → Create Instance

### Placement
- Availability domain: Select Default
- Advance Options:
  - Capacity type: On-Demand Capacity
  - Cluster placement group: Not Applicable ( Network and VM will be managed automatically )
  - Fault Domain: Not Applicable

### Image and shape
- Shape: `VM.Standard.E2.1.Micro` (Always Free: Virtual machine, 1 core OCPU, 1 GB RAM, 0.48 Gbps network bandwidth)
- Image OS: Canonical Ubuntu 22.04 LTS ( Not Minimal or  aarch64 )
- Advance Options:
  - Management:
    - Instance metadata service: NA
    - Initialization script: Default `Choose cloud-init script file`
    - Tagging: Default
### Availability configuration
- Live migration: Let Oracle Cloud Infrastructure choose the best migration option
- Oracle Cloud Agent to enable
  - Compute Instance Monitoring
  - Bastion (optional)

### Security
- Enable Shielded instance

### Networking
- Primary VNIC
  - name: add a meaningful name
  - Primary network: Create new virtual cloud network with a name
  - Subnet: Create new subnet with a name
- Private IPv4 address assignment: Default
- Public IPv4 address assignment : Default
- Advance Options:
  - DNS record: Do not assign a private DNS record
  - Launch options: Default ( Let Oracle Cloud Infrastructure choose the best networking type )
- Configure VCN ( Virtual Cloud Network )
  -  Networking → Virtual Cloud Networks → Your VCN → Subnets → Your Subnet → Security → Your Security List → Security rules → List Ingress Rules
     - Add HTTP (80) rule
         - Source CIDR: 0.0.0.0/0
         - IP Protocol: TCP
         - Destination Port Range: 80
     - Add HTTP (443) rule
         - Source CIDR: 0.0.0.0/0
         - IP Protocol: TCP
         - Destination Port Range: 443

### Add SSH keys
- Generate a key pair for me
- Download both private and public keys

### Boot volume
- Specify a custom boot volume size and performance setting: 50 GB

### Verify Instance Basics (Quick Check)
- Instance state: RUNNING
- Public IPv4 address: Note it down
  - If not present: Go to Instances -> Details -> Instance access -> Public IP address , Click `create public IP`
- Test SSH Connectivity
  - Change mode for private key ( downloaded earlier): `chmod 400 your-key.key`
  - SSH using private key: `ssh -i your-key.key ubuntu@<PUBLIC_IP>`

### Create Directory Structure to organize different services
- Create different directories to manage different services and tools
- `mkdir -p ~/apps/{scripts,proxy,websites,apis,experiments}`

### Create Budget alert
- It it very important to be aware of the billing when it exceeds limit.
- OCI Console → Billing & Cost Management -> Go to Budgets -> Click Create Budget


