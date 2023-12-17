#!/bin/bash

clear

echo "***********************************************************"
echo "BELOW ARE THE LIST OF NAMESPACES PRESENT ON THIS K8 CLUSTER"
echo "***********************************************************"

getns=$(kubectl get ns | awk '{ print $1 }')
readarray -t namespaces < <(kubectl get ns | awk '{ print $1 }')

for i in "${!namespaces[@]}"
  do
    if [[ "$i" == '0' ]]; then
      continue
    fi
    printf '%s\n' "$i : ${namespaces[i]}"
  done

echo ""
echo "CHOOSE THE NAMESPACE YOU WANT TO CHECK PODS IN"
echo ""

read -p "Enter the number corresponding to namespace you want to check: " choice

ns=${namespaces[$choice]}

readarray -t pods < <(kubectl get po -n $ns | awk '{ print $1}') 

clear

echo "****************************************************"
echo "BELOW ARE THE LIST OF PODS PRESENT IN THE NAMESPACE"
echo "****************************************************"

for i in "${!pods[@]}"
  do
    if [[ "$i" == '0' ]]; then
      continue
    fi
    printf '%s\n' "$i : ${pods[i]}"   
  done

read -p "Enter the number corresponding to pod you want to check logs of: " choice

pod=${pods[$choice]}

readarray -t containers < <(kubectl get pod $pod -n $ns -o=jsonpath='{.spec.containers[*].name}')
containers=($containers)

if [[ "${#containers[@]}" -eq '1' ]]; then 
    kubectl logs -n $ns $pod -f
else
    clear
    echo "******************************************"
    echo "BELOW IS THE LIST OF CONTAINERS IN THE POD"
    echo "******************************************"
    for i in "${!containers[@]}"
      do
        printf '%s\n' "$((i+1)) : ${containers[i]}"
      done
    
    read -p "Enter the container you want to check logs of: " choice
    container=${containers[$((choice-1))]}
    echo "CONTAINER SELECTED $container"
    
    kubectl logs -n $ns $pod -c $container -f
fi
