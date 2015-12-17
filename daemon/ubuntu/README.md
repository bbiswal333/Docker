This is a standard Docker daemon configuration file under Ubuntu with:
- SAP proxy
- Docker daemon API opening on tcp port **2375**
- System file containers forced to **devicemapper**
- Container size for all containers managed by the Docker engine extended from default 10G to **70G**
- Docker local storage moved to elsewhere if the **/var/lib/docker** default is located on a too small partition
- Access to registries **dockerdevregistry** and **docker.mo.sap.corp** declared as unsecured
