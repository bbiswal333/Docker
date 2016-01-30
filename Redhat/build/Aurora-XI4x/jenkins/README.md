### Purpose:
Using Jenkins:  
A new Aurora version is dropped in the dropzone, the dropped version is installed in a Docker container, the congtainer is saved to a Docker image, the image is published in the Docker registry, the image is deployed to N containers in a Swarm cluster, ready-to-use for the users, testers or developers for example.

**Hi-level description**  
Three Jenkins jobs is enough to automate the workflow.  

Job 1: Jenkins user server  

- A Jenkins file trigger surveys the change of the file 'version.txt' in the Aurora dropzone.  
  \\\10.17.136.53\dropzone\aurora_dev\aurora42_cons\version.txt  

- A script updates the Github xMake repository with the dropped version properties  
  script: https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/jenkins/PrepAuroraXMake.cmd  
  Github repo: https://github.wdf.sap.corp/AuroraXmake/aurora4xInstall  

Job 2: ci-connect-xMake  
- The Github xMake Aurora repository being registered to ci-connect-xMake services, xMake runs the build

Job 3: Jenkins user server  

- A Docker trigger script surveys the arrival of the new Aurora image in the Docker repository  

- The Swarm deployment script deploys the image on the Swarm nodes  
  script: https://github.wdf.sap.corp/raw/Dev-Infra-Levallois/Docker/master/Redhat/build/Aurora-XI4x/jenkins/deploy.sh  
  
  deploy.sh delegates the deployment to a Swarm deployment pakage script:      https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/swarm/automation/swarmHA-run.sh  
                  https://github.wdf.sap.corp/Dev-Infra-Levallois/Docker/blob/master/swarm/automation/swarm-listnodes.sh  

TO BE CONTINUED  


