### Purpose:
Delivers a ready-to-use testing platform for Shine :  
> Installs HanaDB with XS Monitoring and XS Services, gets the last Shine drop from Github, builds the version with Maven, installs it

**Images productive architecture**  
> Images below are enumerated in the descending order of build frequency, which also  corresponds to the images inheritance graph (**hana-xsa-shine-req** is the base parent)  

- **hana-xsa-shine-req** : installs Hana + XS + Shine system requirements and 3rd party componnents
- (temporary) **hana-installer** : uploads Hana+XS installer once for all
- **hana-xsa**: installs HanaDB and XS Monitoring and XS Services
- **hana-xsa-shine** : gets the last Shine drop from Github, Maven builds the version and generates the installer, the version is installed

**Images alternative architecture**  
- **full-hana-xs-shine** : a global image for the entire installations and processes, an alternative to the Productive architecture above.

**Building an image**  
> Run the **build.sh** script found in the folder  

**hana-installer** folder  
> **upload-installer.sh** script : to reduce the image size, the build creates a temporary folder to copy from the global Hana installer Share only the required files and folders to be uploaded in the container  
> In the definitive productive mode, this intermediate image will be suppressed, the upload will be integrated in the **hana-xsa** image building  

**hana-xsa-shine-ports** folder :  
> On-going development, testing the replacement of the container network model **net=host** with **PortsForwarding** to cohabit several containers on the same host, because the ports range of the Hana instance number does not include the Shine UI port  

**scripts** folder :  
> Sandbox used  for developping  
