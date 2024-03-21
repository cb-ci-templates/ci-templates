def call(String templatePath) {
    node{
        def fileContent = readYaml(file: "templates/${templatePath}/template.yaml")
        echo fileContent
        return fileContent
    }
}
