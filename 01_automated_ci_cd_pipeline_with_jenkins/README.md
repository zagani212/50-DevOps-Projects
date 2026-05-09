# Automated CI/CD pipeline with Jenkins

Directory: **`01_automated_ci_cd_pipeline_with_jenkins`** — numbered prefixes keep the fifty DevOps labs in lesson order inside this repo.

This folder is part of the DevOps projects collection and focuses on continuous integration and delivery using **Jenkins** on Linux.

The sample Maven project used to exercise Jenkins steps (compile, test, static analysis, package, publish) lives in **`jenkins-demo-app/`** under this folder. From the repo root:

```bash
cd 01_automated_ci_cd_pipeline_with_jenkins/jenkins-demo-app
```

---

## Installing Jenkins on Debian 13

Use this guide on a machine running **Debian 13 (“Trixie”)** or a compatible Debian-derived system. Commands assume `sudo` and network access.

### 1. Update the system

Refresh package indexes and install security updates:

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Install Java 21

Jenkins LTS recommends a supported JDK. Install OpenJDK 21 and confirm it:

```bash
sudo apt install openjdk-21-jdk -y
java -version
```

You should see a Java 21 line in the output. If `openjdk-21-jdk` is not available yet on your mirrors, enable **Debian backports** or install another **LTS-supported JDK** version that matches the [current Jenkins JDK requirements](https://www.jenkins.io/doc/book/installing/).

### 3. Install Git and Maven

Useful on the Jenkins controller or build agents for checking out repositories and running Maven builds:

```bash
sudo apt install git -y
sudo apt install maven -y
```

### 4. Add the Jenkins package repository

Jenkins distributes `.deb` packages from their official repository. Create the keyring directory if needed, then add the signing key and the `binary/` suite:

```bash
sudo mkdir -p /etc/apt/keyrings

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
```

### 5. Install Jenkins

```bash
sudo apt install jenkins -y
```

(Optional) Start Jenkins now and enable it on boot:

```bash
sudo systemctl enable --now jenkins
sudo systemctl status jenkins --no-pager
```

Default HTTP port is **8080**.

### 6. First login and wizard

1. Open `http://<your-server-ip>:8080` in a browser (or `http://localhost:8080` on the machine itself).
2. Read the initial admin password:

   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

3. Paste it into the setup screen, then install suggested plugins or select custom plugins as you prefer.
4. Create the first administrator user when prompted.

If you cannot reach port 8080 from another host, configure a firewall (for example **ufw** or **nftables**) to allow TCP **8080**, or put Jenkins behind a reverse proxy with TLS.

---

## Running SonarQube (Docker)

The **`jenkins-demo-app/Jenkinsfile`** runs **SonarQube analysis** and **waits for the quality gate**. SonarQube must be reachable from Jenkins and from the build agents.

Use **`SONAR_HOST`** wherever browser users and Jenkins agents should talk to SonarQube (for example `192.168.1.50` or a DNS name). Use **`JENKINS_HOST`** wherever SonarQube must reach the Jenkins controller for webhooks.

### Start the server

```bash
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
```

Open SonarQube in a browser (**`http://<SONAR_HOST>:9000`**) and sign in with **`admin` / `admin`**. Complete the wizard if prompted (you may be asked to choose a **new administrator password**; use that afterward instead of **`admin`** for login).

If the container exits or logs show Elasticsearch bootstrap errors on **Linux**, increase:

```bash
sudo sysctl -w vm.max_map_count=262144
```

To recreate the container: `docker stop sonarqube && docker rm sonarqube`, then run the `docker run` command again (add a Docker volume if you need analysis history to persist).

### Configure SonarQube (dashboard)

In SonarQube, logged in as an administrator (**`admin`** until you rotate it):

1. **Administration → Configuration → General Settings → General**  
   Set **SonarQube server base URL** to how others should open Sonar (match your network):  

   **`http://<SONAR_HOST>:9000`**

   Save.

2. **Administration → Configuration → Webhooks** → **Create**  
   Tell SonarQube to notify Jenkins when an analysis completes (so **`waitForQualityGate`** reacts quickly):
   - **Name:** **`Jenkins`**
   - **URL:** **`http://<JENKINS_HOST>:8080/sonarqube-webhook/`**  

   Replace **`<JENKINS_HOST>`** with an address the **SonarQube container** can reach—not always `localhost` if Sonar and Jenkins sit on different machines or isolated Docker networks.

3. **Create a Jenkins token in SonarQube**  
   Click your avatar → **Account** → **Security** → **Generate Token**. Copy the token; you paste it into Jenkins in the step below.

### Configure Jenkins

1. **Manage Jenkins → Plugins** → install the **SonarQube Scanner** plugin (Sonar plugin that adds the **SonarQube servers** block and **`/sonarqube-webhook/`** endpoint). Restart Jenkins if the installer prompts you.

2. **Manage Jenkins → System** (“Configure System” in classic Jenkins)—scroll to **SonarQube servers**.

   | Field | Value |
   |--------|--------|
   | **Name** | **`SonarQube`** |
   | **Server URL** | **`http://<SONAR_HOST>:9000`** |
   | **Server authentication token** | **Add → Jenkins → _Secret text_** |

   For the credential:
   - **Secret:** paste the token from SonarQube (**Account → Security**).
   - **ID:** **`sonarqube-token`** (any unique ID works; document this since you reuse it elsewhere).  

   Finish adding the credential, select it from the dropdown, save the system configuration.

The **Name** **`SonarQube`** matches the **`SONARQUBE_INSTALLATION`** pipeline parameter default in **`jenkins-demo-app/Jenkinsfile`**.

---

## Running Nexus Repository Manager (Docker)

Sonatype **Nexus Repository** can host Maven snapshots/releases for CI. Default UI port is **8081** (different from Jenkins **8080**).

On the Docker host, create a data directory owned by **UID/GID 200** so the `nexus` user inside the image can write to the bind mount:

```bash
sudo mkdir -p /opt/nexus-data && sudo chown -R 200:200 /opt/nexus-data
```

Start the container:

```bash
docker run -d -p 8081:8081 --name nexus \
  -v /opt/nexus-data:/nexus-data \
  sonatype/nexus3
```

The first startup can take **one or two minutes** (`docker logs -f nexus` until Nexus reports “started”).

### First login

1. Open **`http://<NEXUS_HOST>:8081`** in a browser (replace **`<NEXUS_HOST>`** with the VM’s IP or DNS name).

2. Read the temporary **admin password** Nexus wrote into the mounted volume:

   ```bash
   docker exec nexus cat /nexus-data/admin.password
   ```

3. Sign in as username **`admin`** with that password, then finish the onboarding wizard—Nexus will ask you to set a **new** administrator password.

After Nexus is migrated to your new credentials, Nexus may delete the temporary file; otherwise you can remove it yourself per Sonatype’s docs.

### Jenkins publishes to Nexus on another VM

If **Jenkins** (controller or Maven agent) and **Nexus** run on **different** machines—typical DevOps layouts—do **not** use `http://localhost:8081` as **`NEXUS_BASE_URL`** in **`jenkins-demo-app/Jenkinsfile` → Build parameters**.

1. Set **`NEXUS_BASE_URL`** to **`http://<PRIVATE_IP_OR_DNS_OF_NEXUS_VM>:8081`** (whatever the Jenkins **executor** resolves and can TCP-connect to).
2. On the **Nexus VM** (or firewall in front): allow inbound **TCP 8081** from the Jenkins/agent subnet (`ufw`, security groups, `iptables`, etc.).
3. If builds run on ephemeral agents/containers behind NAT, **`localhost`** is only correct when Nexus listens on **that same** network namespace—not when Nexus Docker runs on another host.

You can persist a sensible default **`NEXUS_BASE_URL`** in the Jenkins job (**“This project is parameterized”** → defaults) instead of committing your IP into Git.

### Ansible deploy (staging / production)

The **`jenkins-demo-app/Jenkinsfile`** runs **`ansible/playbooks/deploy-jar.yml`** instead of raw **`scp`**. On each Jenkins **executor** that runs the deploy stages, install Ansible (for example **`sudo apt install ansible-core -y`** on Debian/Ubuntu). The playbook copies the built JAR to **`{{ ansible_user_dir }}/<basename of STAGING_REMOTE_JAR or PRODUCTION_REMOTE_JAR>`** (defaults **`~/jenkins-demo-app.jar`** → filename **`jenkins-demo-app.jar`** under the SSH user’s home).

**Staging** Ansible deploy runs on **every** successful pipeline (after artifact publish). **Production** also runs on **any** branch after integration tests: the pipeline pauses for **manual approval**, then runs Ansible to the production VM—use **`input` submitter** restrictions in Jenkins if you need branch- or role-based control.

---

## References

- [Jenkins Debian/Ubuntu installation](https://www.jenkins.io/doc/book/installing/linux/#debianubuntu)
- [Jenkins Debian package repository](https://pkg.jenkins.io/debian-stable/)
- [SonarQube Server with Docker](https://docs.sonarsource.com/sonarqube-server/latest/setup-and-upgrade/install-the-server/installing-sonarqube-from-docker/)
- [Sonatype Nexus Repository (Docker Hub)](https://hub.docker.com/r/sonatype/nexus3/)
