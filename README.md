# K8Utilities
This repository will have generalized utility tools for a Kubernetes cluster

1. podLogs.sh:
   This shell script will be used to read pod/container logs of any pod running on the cluster. We need to choose namespace and then pod name and then the specific container 
   name (in case of multiple containers), to read the logs. The logs are tailed instead of just being output in the terminal, so manual interruption is required to stop.
   Future improvements will include the option whether to tail or not tail the logs, and allowing option to go in previous menu instead of shell shutdown.
