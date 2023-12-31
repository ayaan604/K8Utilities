# K8Utilities
This repository will have generalized utility tools for a Kubernetes cluster

1. podLogs.sh:
   This shell script will be used to read pod/container logs of any pod running on the cluster. We need to choose namespace and then pod name and then the specific container 
   name (in case of multiple containers), to read the logs. The logs are tailed for the last 100 lines as of now, improvements in options to be introduced pretty soon.

   Special mention to @hritikkanojiya, as his personal shell scripts and his committment to streamlining the code have a direct influence in the code of these scripts...
   
