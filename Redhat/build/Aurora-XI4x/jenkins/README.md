### Purpose:
Using Jenkins, generates the Docker image of a new Aurora dropped version and instanciates its containers in a Swarm cluster  

### Hi-level description
A new Aurora version is dropped in the dropzone, the dropped version is installed in a Docker container, the container is saved to a Docker image, the image is published to the Docker registry, the image is deployed to N containers in a Swarm cluster, the list of machineNames of deployed nodes is returned in a text file, delivering a ready-to-use platform for the users, testers or developers for example.

### Low-level details  
3 Jenkins jobs automate the workflow.  

> `dockerdevregistry` is the currently used  Docker registry. `Artifactory` will be used as soon as in production

**Platform**:  
- A user Jenkins server (Windows)
- A user Jenkins slave (Linux) authorized to send commands to the Swarm cluster

**JOB 1: Jenkins user server**  

- A Jenkins file trigger surveys the change of the file 'version.txt' in the Aurora dropzone.  
  [file:\\\10.17.136.53\dropzone\aurora_dev\aurora42_cons\version.txt]  
  Execution: `User Jenkins Master`  
  
- A Windows script updates the Github xMake repository with the dropped version properties  
  script: https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/Redhat/build/Aurora-XI4x/jenkins/XMakeRepo.cmd  
  Execution: `User Jenkins Master`

  Github repo: https://github.wdf.sap.corp/AuroraXmake/aurora4xInstall  

**JOB 2: ci-connect-xMake**  
- The Aurora Github xMake repository being registered to ci-connect-xMake services, xMake runs the build

**JOB 3: Jenkins user server**  

- A Docker trigger Shell script surveys the arrival of the new Aurora image in the Docker repository  
  https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/Redhat/build/Aurora-XI4x/jenkins/dockerdevregistryTrigger.sh  
  Execution: `User Jenkins slave (Linux)`

- A Shell script runs the deployment by delegation to the Shell scripts of the Swarm deployment package  
  https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/Redhat/build/Aurora-XI4x/jenkins/deploy.sh  
  Execution: `User Jenkins slave (Linux)`  
  
  Delegated Swarm deployment scripts:  
  To deploy the containers: https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/swarm/automation/swarmHA-run.sh  
  To list nodes installed with the image: 
  https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/swarm/automation/swarm-listnodes.sh  
  Execution: `User Jenkins slave (Linux)`  


