# Required Plugins
* [config-file-provider](https://plugins.jenkins.io/config-file-provider/) 
* [pipeline-utility-steps](https://plugins.jenkins.io/pipeline-utility-steps/) 
* [Pipeline Maven](https://plugins.jenkins.io/pipeline-maven/)
* [CloudBees Workspace Caching](https://github.com/jenkinsci/artifact-manager-s3-plugin)
  * https://docs.cloudbees.com/docs/release-notes/latest/plugins/cloudbees-s3-cache-plugin
  * https://docs.cloudbees.com/docs/release-notes/latest/plugins/cloudbees-cache-step-plugin
* [WarningsNextNG](https://plugins.jenkins.io/warnings-ng/)
* TODO verify and add required Plugin

# Maven Settings

If maven-settings are required, for example when http-proxies are required, maven needs to know where to get its maven settings file from.

For example: See [maven-proxy-settings.xml](../../config/maven-proxy-settings.xml)

```
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

There are several ways known on how to manage maven settings files across distributed  procecs.
Using a common share, reading from configmaps etc.

However, here we use the Configfile provider plugin to manage the maven-settings file for us
We reference the maven settings file from our maven build step: https://github.com/cb-ci-templates/ci-shared-library/blob/3fbf41a52111875bb4b771ad8cac64d7108a0d55/vars/buildMaven.groovy#L11
See https://github.com/cb-ci-templates/ci-shared-library/blob/main/vars/buildMaven.groovy

```
        withMaven(
                ...
                // Maven settings.xml file defined with the Jenkins Config File Provider Plugin
                // We recommend to define Maven settings.xml globally at the folder level using
                // navigating to the folder configuration in the section "Pipeline Maven Configuration / Override global Maven configuration"
                // or globally to the entire master navigating to  "Manage Jenkins / Global Tools Configuration"
                mavenSettingsConfig: 'my-maven-settings'
        ) {

```

In CasC, the setup looks like this:
See [jenkins.yaml](../../casc/controller/controller-ci-templates/jenkins.yaml)
````
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
````


# Maven Cache

To avoid loading maven dependencies again for each new build, we use a simple host path volume mount to accelerate the build performance using a local maven cache. 

See [maven-cache-pvc.yaml](../../config/maven-cache-pvc.yaml)

This volume will be mounted to the related build pod
See https://github.com/cb-ci-templates/ci-shared-library/blob/main/vars/buildMaven.groovy
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
      volumeMounts:
        - name: maven-cache
          mountPath: /tmp/.m2
....
  volumes:
    - name: maven-cache
      persistentVolumeClaim:
        claimName: maven-repo
```

and the maven step will reference to the mounted volume

See https://github.com/cb-ci-templates/ci-shared-library/blob/main/vars/buildMaven.groovy
```
        withMaven(
                //Use `$WORKSPACE/.repository` for local repository folder to avoid shared repositories
                //consider to use CloudBees Workspace caching https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/cloudbees-cache-step
                mavenLocalRepo: '/tmp/.m2',
                ....
        ) {

```


Note: This approach is simple, but just used for the demo purpose of this repository. In production, other approaches should be considered. (Will not be discussed here)


Create the cache volume:

```kubectl apply -f config/maven-cache-pvc.yaml```

# Environment Variables 

# Credentials

## kaniko

* docker-config.json as string credential (Secret Text)

```
{
  "auths": {
    "https://index.docker.io/v1/": {
      "username": "....",
      "password": "....",
      "email": "xxxx@yyy.com",
      "auth": "....."
    }
  }
}
```

## GitHub

* GitHub App authentication is required, see https://docs.cloudbees.com/docs/cloudbees-ci/latest/cloud-admin-guide/github-app-auth


##  Credentials CasC
```
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


A simple Dockerfile to build with kaniko, see https://docs.cloudbees.com/docs/cloudbees-core/latest/cloud-admin-guide/using-kaniko#_create_a_new_kubernetes_secret   for further details


