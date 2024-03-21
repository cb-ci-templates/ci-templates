def call(String templatePath) {
    def fileContent = readYaml(file: "${WORKSPACE}/templates/${templatePath}/template.yaml")
    echo fileContent
    return fileContent
}