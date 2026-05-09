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

The **`jenkins-demo-app/Jenkinsfile`** runs **SonarQube analysis** and **waits for the quality gate**. You need a SonarQube server reachable from your Jenkins agent; here it is started as a **Docker** container on the same machine or another host.

### Start the server

```bash
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
```

- **Web UI:** `http://localhost:9000` (or `http://<docker-host-ip>:9000` from another machine).
- **First login:** SonarQube ships with default credentials **`admin` / `admin`** and will prompt you to change the password.
- **Jenkins:** In **Manage Jenkins → Configure System → SonarQube servers**, set **Server URL** to that same base URL (for example `http://<sonar-host>:9000`) and add a **token** from SonarQube (**User → My Account → Security** → Generate Token). The server **Name** there must match the **`SONARQUBE_INSTALLATION`** parameter in the pipeline (default **`SonarQube`**).

If the container exits or logs show Elasticsearch bootstrap errors on **Linux**, increase the host limit (SonarQube’s embedded search layer often needs this):

```bash
sudo sysctl -w vm.max_map_count=262144
```

To remove and recreate the container later: `docker stop sonarqube && docker rm sonarqube` before running `docker run` again (or use `docker rename` / volume mounts only if you need to persist data).

---

## References

- [Jenkins Debian/Ubuntu installation](https://www.jenkins.io/doc/book/installing/linux/#debianubuntu)
- [Jenkins Debian package repository](https://pkg.jenkins.io/debian-stable/)
- [SonarQube Server with Docker](https://docs.sonarsource.com/sonarqube-server/latest/setup-and-upgrade/install-the-server/installing-sonarqube-from-docker/)
