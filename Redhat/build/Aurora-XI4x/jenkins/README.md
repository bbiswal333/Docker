### Purpose:
Using Jenkins:  
A new Aurora version is dropped in the dropzone, the dropped version is installed in a Docker container, the congtainer is saved to a Docker image, the image is published in the Docker registry, the image is deployed to N containers in a Swarm cluster, ready-to-use for the users, testers or developers for example.

**Hi-level description**  
Three Jenkins jobs is enough to automate the workflow.  

Job 1: Jenkins user server  
- A Jenkins file trigger surveys the change of the file 'version.txt' in the Aurora dropzone.  
- A script updates the Github xMake repository with the dropped version properties  

Job 2: ci-connect-xMake  
- The Github xMake Aurora repository being registered to ci-connect-xMake services, xMake runs the build

Job 3: Jenkins user server  
- A Docker trigger script surveys the arrival of the new Aurora image in the Docker repository
- The Swarm deployment script deploys the image on the Swarm nodes  

TO BE CONTINUED  


