### Purpose:
Using Jenkins, generates the Docker image of a new Aurora dropped version and instanciates its containers in a Swarm cluster  

### Hi-level description
A new Aurora version is dropped in the dropzone, the dropped version is installed in a Docker container, the container is saved to a Docker image, the image is published to the Docker registry, the image is deployed to N containers in a Swarm cluster, the list of machineNames of deployed nodes is returned in a text file, delivering a ready-to-use platform for the users, testers or developers for example.

### Low-level details  
3 Jenkins jobs automate the workflow.  

> `dockerdevregistry.wdf.sap.corp` is the currently used  Docker registry. `Artifactory` will be used as soon as in production

**Platform**:  
- The corporate ci-connnect / xMake server
- A user Jenkins server (Windows)
- A user Jenkins slave (Linux) authorized to send commands to the Swarm cluster

**JOB 1: Jenkins user server**  

- A Jenkins file trigger surveys the change of the file 'version.txt' in the Aurora dropzone.  
  
  Executed on: `User Jenkins Master`  
  [file:\\\10.17.136.53\dropzone\aurora_dev\aurora42_cons\version.txt]  
  Trigger log example: http://10.97.154.68:8080/job/OnAuroraDrop1_Configure_xMake/39/triggerCauseAction/  
  
- A Windows script updates the Github xMake repository with the dropped version properties  
  The matter of an impersonal Github account is solved using a Github PersonalAccessToken.  
  
  Executed on: `User Jenkins Master`  
  script: https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/Redhat/build/Aurora-XI4x/jenkins/XMakeRepo.cmd  
  Log example: http://10.97.154.68:8080/job/OnAuroraDrop1_Configure_xMake/39/console  

  Github repo: https://github.wdf.sap.corp/AuroraXmake/aurora4xInstall  

**JOB 2: ci-connect-xMake**  
- The Aurora Github xMake repository being registered to ci-connect-xMake services, xMake runs the build  
  
  Log example: https://xmake-dev.mo.sap.corp:8443/job/AuroraXmake-aurora4xInstall-master-CI-docker_xs/61/console  

**JOB 3: Jenkins user server**  

- A Docker trigger Shell script surveys the arrival of the new Aurora image in the Docker repository  
  
  Executed on: `User Jenkins slave (Linux)`  
  Script: https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/Redhat/build/Aurora-XI4x/jenkins/dockerdevregistryTrigger.sh  
  Trigger log example: http://10.97.154.68:8080/job/OnAuroraDrop2_DeployTo_Swarm/43/triggerCauseAction/  

- A Shell script runs the deployment by delegation to the Shell scripts of the Swarm deployment package  
  
  Executed on: `User Jenkins slave (Linux)`  
  Script: https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/Redhat/build/Aurora-XI4x/jenkins/deploy.sh  
  Log example: http://10.97.154.68:8080/job/OnAuroraDrop2_DeployTo_Swarm/43/console  
  
  Delegated Swarm deployment scripts:  
  
  To deploy the containers:  
  Executed on: `User Jenkins slave (Linux)`  
  Script: https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/swarm/automation/swarmHA-run.sh  
  
  To list nodes installed with the image:  
  Executed on: `User Jenkins slave (Linux)`  
  Script: https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/swarm/automation/swarm-listnodes.sh  
