### Purpose:
Using Jenkins:  
A new Aurora version is dropped in the dropzone, the dropped version is installed in a Docker container, the image is published in the Docker registry, the image is deployed as N containers in a Swarm cluster, ready-to-use for testing for example.

**Hi-level description**  
Three Jenkins jobs is enough to automate the workflow.  
Jenkins Job 1:  
- A Jenkins file trigger surveys the change of the file 'version.txt' in the Aurora dropzone.  
- A script updates the Github xMake repository with the dropped version properties  

ci-connect-xMake job  
- The Github xMake Aurora repository being registered to ci-connect-xMake services, xMake runs the build

Jenkins Job 2:  
- A Docker trigger script surveys the arrival of the new Aurora image in the Docker repository
- The Swarm deployment script deploys the image on the Swarm nodes  

TO BE CONTINUED  


