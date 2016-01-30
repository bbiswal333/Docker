### Purpose:
Using Jenkins generates the Docker image of a new Aurora dropped version and instanciates its containers in a Swarm cluster  

### Hi-level description
A new Aurora version is dropped in the dropzone, the dropped version is installed in a Docker container, the container is saved to a Docker image, the image is published to the Docker registry, the image is deployed to N containers in a Swarm cluster, the list of machineNames of deployed nodes is returned in a text file, delivering a ready-to-use platform for the users, testers or developers for example.

### Low-level details  
3 Jenkins jobs automate the workflow.  

> The Docker registry currently used is `dockerdevregistry`.  
  `Artifactory` will be used as soon as in production

**JOB 1: Jenkins user server**  

- A Jenkins file trigger surveys the change of the file 'version.txt' in the Aurora dropzone.  
  \\\10.17.136.53\dropzone\aurora_dev\aurora42_cons\version.txt  

- A script updates the Github xMake repository with the dropped version properties  
  script: https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/jenkins/PrepAuroraXMake.cmd  
  
  Github repo: https://github.wdf.sap.corp/AuroraXmake/aurora4xInstall  

**JOB 2: ci-connect-xMake**  
- The Github xMake repository being registered to ci-connect-xMake services, xMake runs the build

**JOB 3: Jenkins user server**  

- A Docker trigger script surveys the arrival of the new Aurora image in the Docker repository  
  https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/Redhat/build/Aurora-XI4x/jenkins/dockerTrigger.sh  

- A script runs the deployment by delegation to scripts of the Swarm deployment package  
  https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/jenkins/deploy.sh  
  
  Delegated Swarm deployment scripts:  
  To deploy: https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/swarm/automation/swarmHA-run.sh  
  To list nodes installed with the image: 
  https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/swarm/automation/swarm-listnodes.sh  

