
# Required Plugins

* [config-file-provider](https://plugins.jenkins.io/config-file-provider/)
* [pipeline-utility-steps](https://plugins.jenkins.io/pipeline-utility-steps/)
* [Pipeline Maven](https://plugins.jenkins.io/pipeline-maven/)
* [CloudBees Workspace Caching](https://github.com/jenkinsci/artifact-manager-s3-plugin)
  * https://docs.cloudbees.com/docs/release-notes/latest/plugins/cloudbees-s3-cache-plugin
  * https://docs.cloudbees.com/docs/release-notes/latest/plugins/cloudbees-cache-step-plugin
* [WarningsNextNG](https://plugins.jenkins.io/warnings-ng/)
* TODO: Verify and add any additional required plugins.

# Maven Settings

If Maven settings are required (e.g., for HTTP proxies), you need to define a Maven settings file.

Example: [maven-proxy-settings.xml](../../config/maven-proxy-settings.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <proxies>
        <proxy>
            <id>myproxy</id>
            <active>true</active>
            <protocol>http</protocol>
            <host>squid-dev-proxy.squid.svc.cluster.local</host>
            <port>3128</port>
            <nonProxyHosts>localhost|127.0.0.1|*.svc.cluster.local|*.beescloud.com|127.*|[::1]</nonProxyHosts>
        </proxy>
    </proxies>
</settings>
```

**Management Options:**

Multiple strategies exist for distributing `settings.xml` (e.g., via shared volumes or config maps). This example uses the Config File Provider Plugin.

**Usage in Jenkins Pipeline:**  
[buildMaven.groovy - Reference](https://github.com/cb-ci-templates/ci-shared-library/blob/main/vars/buildMaven.groovy)

```groovy
withMaven(
    ...
    mavenSettingsConfig: 'my-maven-settings'
) {
    // Maven tasks here
}
```

**Configuration as Code (CasC):**  
Example snippet from [jenkins.yaml](../../casc/controller/controller-ci-templates/jenkins.yaml)

```yaml
unclassified:
  globalConfigFiles:
    configs:
    - globalMavenSettings:
        comment: "Global settings"
        content: |
          <?xml version="1.0" encoding="UTF-8"?>
          <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
              <proxies>
                  <proxy>
                      <id>myproxy</id>
                      <active>true</active>
                      <protocol>http</protocol>
                      <host>squid-dev-proxy.squid.svc.cluster.local</host>
                      <port>3128</port>
                      <nonProxyHosts>localhost|127.0.0.1|*.svc.cluster.local|*.beescloud.com|127.*|[::1]</nonProxyHosts>
                  </proxy>
              </proxies>
          </settings>
        id: "my-maven-settings"
        isReplaceAll: true
        name: "my-maven-settings"
        providerId: "org.jenkinsci.plugins.configfiles.maven.GlobalMavenSettingsConfig"
```

# Maven Cache

To avoid re-downloading dependencies for each build, a local Maven cache is used via a volume mount.

**PVC Definition:**  
See [maven-cache-pvc.yaml](../../config/maven-cache-pvc.yaml)

**Pod Template Snippet:**

```yaml
kind: Pod
metadata:
  name: maven
spec:
  containers:
    - name: maven
      image: maven:3.9.9-amazoncorretto-17
      envFrom:
        - configMapRef:
            name: configmap-envvars
      volumeMounts:
        - name: maven-cache
          mountPath: /tmp/.m2
  volumes:
    - name: maven-cache
      persistentVolumeClaim:
        claimName: maven-repo
```

**Pipeline Usage:**  
[buildMaven.groovy - Reference](https://github.com/cb-ci-templates/ci-shared-library/blob/main/vars/buildMaven.groovy)

```groovy
withMaven(
    mavenLocalRepo: '/tmp/.m2',
    ...
) {
    // Maven tasks here
}
```

> **Note:** This cache setup is for demonstration purposes. Consider more robust caching strategies for production.

**Create the cache volume:**

```sh
kubectl apply -f config/maven-cache-pvc.yaml
```

# Environment Variables

Required environment variables can be injected like this:

Create a Kubernetes config map with required variables:
See [configmap-env-vars-proxy.yaml](../../config/configmap-env-vars-proxy.yaml)

```
cat <<EOF | kubelctl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: configmap-envvars
data:
  HTTP_PROXY:  http://squid-dev-proxy.squid.svc.cluster.local:3128
  HTTPS_PROXY: http://squid-dev-proxy.squid.svc.cluster.local:3128
  NO_PROXY:    localhost,127.0.0.1,.svc.cluster.local,.cluster.local,.beescloud.com
  http_proxy:  http://squid-dev-proxy.squid.svc.cluster.local:3128
  https_proxy: http://squid-dev-proxy.squid.svc.cluster.local:3128
  no_proxy:    localhost,127.0.0.1,.svc.cluster.local,.cluster.local,.beescloud.com
EOF
```

Mount Configmap into build pod:

```
kind: Pod
metadata:
  name: maven
spec:
  containers:
    - name: maven
      image: maven:3.9.9-amazoncorretto-17
      envFrom:
        - configMapRef:
            name: configmap-envvars
 ....
```



# Credentials

## Kaniko

Use Docker `config.json` as a secret text credential.

```json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "username": "...",
      "password": "...",
      "email": "xxxx@yyy.com",
      "auth": "..."
    }
  }
}
```

## GitHub

Use GitHub App authentication:  
https://docs.cloudbees.com/docs/cloudbees-ci/latest/cloud-admin-guide/github-app-auth

## Credentials in CasC

```yaml
credentials:
  system:
    domainCredentials:
    - credentials:
      - gitHubApp:
          appID: "12345"
          description: "ci-template-gh-app"
          id: "ci-template-gh-app"
          privateKey: ${....}
      - string:
          description: "dockerconfig"
          id: "dockerconfig"
          scope: GLOBAL
          secret: ${....}
```

For Kaniko Docker builds, see:  
https://docs.cloudbees.com/docs/cloudbees-core/latest/cloud-admin-guide/using-kaniko#_create_a_new_kubernetes_secret
