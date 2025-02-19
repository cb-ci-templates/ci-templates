| File                                                 | Description                                                                               | col3 |
| ---------------------------------------------------- | ----------------------------------------------------------------------------------------- | ---- |
| 00-setupGKEFilestore.sh                              | create filestore in GCP                                                                   |      |
| 01-installTools.sh                                   | create a PVC and a tools-pod, installs java for testing purposes on the tools volume      |      |
| tools-volume-pvc.yml                                 | k8s resource for the PVC and the POD                                                      |      |
| Jenkinsfile-declarative-pipeline-tools-volume.groovy | Jenkins declarative Test Pipeline, uses inline pod yaml                                   |      |
| Jenkinsfile-scripted-pipeline-tools-volume.groovy    | Jenkins scripted Test Pipeline, referncess to label, allocate a pod from k8s pod template |      |
| casc-k8s-podtemplate.yaml                            | casc config for the k8s-podtemplate                                                      |      |


Quickstart


* adjust the cariables in `00-setupGKEFilestore.sh` then run the scriot to enable the file store CSI driver in your cluster
* run `01-installTools.sh` to install a tool on the volume
* run the `Jenkinsfile-declarative-pipeline-tools-volume` on our controller
* apply `casc-k8s-podtemplate.yaml` on your Controller to test the `Jenkinsfile-scripted-pipeline-tools-volume`
