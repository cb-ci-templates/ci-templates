Add `<username>` and `<password>` under your `<proxy>` element. Plain-text works, but I strongly recommend using Maven’s built-in password encryption or Configfile-provider user/password variable injection
See:
* https://docs.cloudbees.com/docs/cloudbees-ci-kb/latest/best-practices/best-practices-for-managing-maven-configurations-in-jenkins
* https://plugins.jenkins.io/config-file-provider/
* https://plugins.jenkins.io/pipeline-maven 

## Quick (plain-text)

```xml
<settings ...>
  <proxies>
    <proxy>
      <id>myproxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>squid-dev-proxy.squid.svc.cluster.local</host>
      <port>3128</port>
      <username>MY_USER</username>
      <password>MY_PASSWORD</password>
      <nonProxyHosts>localhost|127.0.0.1|*.svc.cluster.local|*.xxx.com|127.*|::1</nonProxyHosts>
    </proxy>
  </proxies>
</settings>
```

For ConfigFile provider

```xml
<settings ...>
  <proxies>
    <proxy>
      <id>myproxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>squid-dev-proxy.squid.svc.cluster.local</host>
      <port>3128</port>
      <username>${proxyusser}</username>
      <password>${proxypassword}</password>
      <nonProxyHosts>localhost|127.0.0.1|*.svc.cluster.local|*.xxx.com|127.*|::1</nonProxyHosts>
    </proxy>
  </proxies>
</settings>
```

> Note: in `nonProxyHosts`, use `::1` (no brackets). Brackets are for URLs, not host matching.

## Recommended (encrypted password) when not using the jenkins credentials store and Configfile provider injection:

1. Create (once) a **master password** and put it in `~/.m2/settings-security.xml`:

```bash
mvn --encrypt-master-password
# copy the output {...} into ~/.m2/settings-security.xml as:
# <settingsSecurity><master>{...}</master></settingsSecurity>
```

2. Encrypt your **proxy** password:

```bash
mvn --encrypt-password
# paste your real proxy password when prompted; copy the {...} output
```

3. Use the encrypted value in `settings.xml`:

```xml
<settings ...>
  <proxies>
    <proxy>
      <id>myproxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>squid-dev-proxy.squid.svc.cluster.local</host>
      <port>3128</port>
      <username>MY_USER</username>
      <password>{6dHG3...encrypted...==}</password>
      <nonProxyHosts>localhost|127.0.0.1|*.svc.cluster.local|*.xxx.com|127.*|::1</nonProxyHosts>
    </proxy>
  </proxies>
</settings>
```

## Extras / gotchas

* **Protocol**: keep `<protocol>http</protocol>` for a typical CONNECT proxy (like Squid). Only use `https` if your proxy itself is reached over HTTPS.
* **NTLM/AD** proxies\*\*:\*\* try `DOMAIN\user` or `user@domain.tld` in `<username>`.
* **Verify Maven sees it**:
  ```bash
  mvn -X help:effective-settings | sed -n '/<proxies>/,/<\/proxies>/p'
  ```
* **Jenkins/Kubernetes agents**: mount this `settings.xml` to `/root/.m2/settings.xml` (or the Maven user’s home) in the build container so all builds use the proxy consistently.
