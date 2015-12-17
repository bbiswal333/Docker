### Purpose:
Deploy a swarm cluster with Zookeeper as discovery service

**swarm-deploy.sh:**  
Read the variables in __swarm-request.ini__ and deploy the cluster.

**dockerhost.sh**  
Takes the role of a clustering layer, searching the first alive Swarm-manager cluster member that responds.  
Reads __swarm-request.ini__ to retrieve the Swarm-managers and the manager port.  
> dockerhost.sh must be located at the same place as swarm-request.ini.  

Usage: `./dockerhost.sh <parameters>` to replace the native command `docker -H <host>:<port> <parameters>`  
Example: `./dockerhost ps -a`

**swarm-request.ini**  
If `zookeepers=` and `managers=` contains several machines, the machines are gathered in clusters.  
3 machines at least are required to build a cluster.  
If `zooLB=` or `managerLB=` are defined, a load balancer is inserted as endpoint.  

*Remark*: load balancer solution is discouraged, failover becomes possible and the cluster benefit is lost.

**swarm-request.log**  
Logs the commands ran to create containers : Zookeeper, Swarm-Managers, Swarm-Nodes

**Consul vs Zookeeper**  
Zookeeper is preferable to Consul:
- more reliable
- Swarm-managers and Swarm-nodes container creation accepts all ZK servers while only one endpoint is accepted with Consul.
  It means: with ZK Swarm-managers manages by itself the ZK failover. It's not the case with Consul

**HighEST Availability recommendations**
- Zookeeper, not Consul
- Zookeeper and Swarm-Managers in clusters
- No load balancers
- `./dockerhost.sh` as Swarm-Managers clustering service