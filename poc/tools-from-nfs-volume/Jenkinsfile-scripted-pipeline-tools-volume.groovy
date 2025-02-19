node("tools"){
    env.JAVA_HOME="/tools/tools-linux/java/jdk-23.0.2"
    env.PATH="$PATH:$JAVA_HOME/bin"
    sh "java --version"
}