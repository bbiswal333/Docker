**Building the image**
  
    # Expected <URL> is the location to download the SAR Hana installer from
    ./DockerBuildHana.sh  <URL>

    # Example:
    # ./DockerBuildHana.sh  "http://moo-repo.wdf.sap.corp:8080/static/pblack/newdb/NewDB100/rel/094/server/linuxx86_64/"


  **Running a container**

    # The expected parameter <HanaInstanceNumber> will rename the Hana instance number in the image
    ./DockerRunHana.sh <HanaInstanceNumber>
  
  
