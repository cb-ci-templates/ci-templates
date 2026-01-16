# Maven Proxy Configuration Guide

In Enterprise environments like CloudBees CI, outbound traffic is often restricted and requires a proxy (e.g., Squid) to reach external repositories or centralized Nexus/Artifactory instances.

> [!IMPORTANT]
> For CloudBees CI, the **Recommended** approach is using the [Config File Provider](https://plugins.jenkins.io/config-file-provider/) to inject credentials securely into your `settings.xml`.

---

## 1. Quick Start (Plain Text)

Use this for local testing or troubleshooting. Avoid hardcoding passwords in production.

```xml
<settings ...>
  <proxies>
    <proxy>
      <id>enterprise-proxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>squid-proxy.svc.cluster.local</host>
      <port>3128</port>
      <username>MY_USER</username>
      <password>MY_PASSWORD</password>
      <nonProxyHosts>localhost|127.0.0.1|*.svc.cluster.local|*.xxx.com|127.*|::1</nonProxyHosts>
    </proxy>
  </proxies>
</settings>
```

---

## 2. CloudBees CI Recommended (Config File Provider)

This method avoids plain-text passwords in your repository by using Jenkins Credentials.

1.  **Create Credentials**: In CloudBees CI, create a "Username with password" credential.
2.  **Define Managed File**: Go to **Manage Jenkins** -> **Managed files** -> **Add a new Config** -> **Maven settings.xml**.
3.  **Inject Variables**: Use the following snippet in your managed `settings.xml`:

```xml
<settings ...>
  <proxies>
    <proxy>
      <id>managed-proxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>squid-proxy.svc.cluster.local</host>
      <port>3128</port>
      <username>${proxyuser}</username>
      <password>${proxypassword}</password>
      <nonProxyHosts>localhost|127.0.0.1|*.svc.cluster.local|*.xxx.com|127.*|::1</nonProxyHosts>
    </proxy>
  </proxies>
</settings>
```

> [!TIP]
> In your Pipeline, use the `configFileProvider` step to map these variables:
> ```groovy
> configFileProvider([configFile(fileId: 'my-maven-settings', variable: 'MAVEN_SETTINGS')]) {
>     sh "mvn -s $MAVEN_SETTINGS clean install"
> }
> ```

---

## 3. Advanced: Encrypted Passwords (Manual Setup)

Recommended when not using Jenkins credentials (e.g., local developer machines or manual agents).

1.  **Create Master Password**:
    ```bash
    mvn --encrypt-master-password
    ```
    Store the `{...}` output in `~/.m2/settings-security.xml`:
    ```xml
    <settingsSecurity>
      <master>{...}</master>
    </settingsSecurity>
    ```

2.  **Encrypt Proxy Password**:
    ```bash
    mvn --encrypt-password
    ```
    Paste the output into your `settings.xml`:
    ```xml
    <password>{6dHG3...encrypted...==}</password>
    ```

---

## Extras & Troubleshooting

- **nonProxyHosts**: Use `::1` for IPv6 loopback (no brackets needed). Ensure internal cluster domains (e.g., `*.svc.cluster.local`) are excluded to avoid routing internal traffic through the proxy.
- **Protocol**: Use `<protocol>http</protocol>` for standard CONNECT proxies. Only use `https` if the proxy server itself requires an SSL/TLS connection.
- **NTLM/AD Proxies**: Try formats like `DOMAIN\user` or `user@domain.com`.
- **Validation**: Verify Maven is correctly picking up the proxy configuration:
  ```bash
  mvn -X help:effective-settings | sed -n '/<proxies>/,/<\/proxies>/p'
  ```
- **Kubernetes Agents**: Mount the `settings.xml` (or use ConfigFile Provider) to ensure all ephemeral agents inherit the correct proxy settings consistently.

---

### External Links
- [CloudBees Best Practices: Maven in Jenkins](https://docs.cloudbees.com/docs/cloudbees-ci-kb/latest/best-practices/best-practices-for-managing-maven-configurations-in-jenkins)
- [Pipeline Maven Integration Plugin](https://plugins.jenkins.io/pipeline-maven)
