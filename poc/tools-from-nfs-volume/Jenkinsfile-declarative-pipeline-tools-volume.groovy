// Uses Declarative syntax to run commands inside a container.
pipeline {
    agent {
        //you can also reference by label
        //label "tools"

        //but for demo we use inline pod yaml
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  name: tools-pod
spec:
  containers:
    - name: shell
      image: amazonlinux
      command:
      - sleep
      args:
      - infinity
      volumeMounts:
        - mountPath: /tools
          name: tools-volume
      securityContext:
        # ubuntu runs as root by default, it is recommended or even mandatory in some environments (such as pod security admission "restricted") to run as a non-root user.
        runAsUser: 1000
  volumes:
    - name: tools-volume
      persistentVolumeClaim:
        claimName: tools-pvc
'''
            defaultContainer 'shell'
            retries 2
        }
    }
    stages {
        stage('Main') {
            environment {
                JAVA_HOME="/tools/tools-linux/java/jdk-23.0.2"
                PATH="$PATH:$JAVA_HOME/bin"
            }
            steps {
                sh 'java --version'
            }
        }
    }
}
