### Purpose:
Delivers a ready-to-use testing platform for Shine :
Installs HanaDB with XS Monitoring and XS Services, gets the last Shine drop from Github, builds the version with Maven, installs it

**Images productive architecture**  
Images are enumerated in the descending order of build frequency, which also  corresponds to the images inheritance graph (first image is the base parent)
- hana-xsa-shine-req : installs Hana and XS and Shine system requirements and 3rd party componnents
- (TEMPORARY) hana-installer: uploads Hana+XS installer once for all
- hana-xsa: installs HanaDB and XS Monitoring and XS Services
- hana-xsa-shine : gets the last Shine drop from Github, Maven builds the version and generates the installer, the version is installed

**Images alternative architecture**  
- full-hana-xs-shine : a global image for the entire installations and processes, an alternative to the Productive architecture

**scripts** folder is a sandbox that was used to for the dev
