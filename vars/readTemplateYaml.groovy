def call(String templatePath) {
    def fileContent = readYaml(file: "templates/${templatePath}/template.yaml")
    echo fileContent
    return fileContent
}