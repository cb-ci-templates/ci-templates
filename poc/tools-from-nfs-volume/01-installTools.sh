#! /bin/sh

kubectl apply -f tools-volume-pvc.yml
kubectl exec -i tools-pod -- /bin/sh -c "$(cat <<'EOF'
echo "Starting process..."
date
echo "Hello from the tools command!"
yum install tar gzip
mkdir -p /tools/tools-linux/java/
cd /tools/tools-linux/java/
rm -fv *.tar.gz
curl -o java23.tar.gz https://download.java.net/java/GA/jdk23.0.2/6da2a6609d6e406f85c491fcb119101b/7/GPL/openjdk-23.0.2_linux-x64_bin.tar.gz
ls -la
chmod a+x *.tar.gz
tar -xvzf java23.tar.gz
export JAVA_HOME="/tools/tools-linux/java/jdk-23.0.2"
export PATH="$PATH:$JAVA_HOME/bin"
java --version
EOF
)"
