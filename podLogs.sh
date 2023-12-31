#!/bin/bash

# This utility will be used to view pod logs 

handle_error() {
    clear
    echo "Error: $2"
    [ "$1" != false ] && {
        echo "Terminating script..."
        echo ''
        exit 1
    }    
}

containers_list(){
  clear
  while true; do
    echo "******************************************"
    echo "BELOW IS THE LIST OF CONTAINERS IN THE POD"
    echo "******************************************"
    echo "0 : Exit"
    for i in "${!containers[@]}"
      do
        echo "$((i+1)) : ${containers[i]}"
      done

    read -p "Enter the container you want to check logs of: " choice

    if [[ $choice -eq '0' ]]; then
      clear
      break
    fi
    container=${containers[$((choice-1))]}

    kubectl logs -n $ns $pod -c $container --tail=100
    echo "";echo "";
  done
}

pod_logs(){
  readarray -t containers < <(kubectl get pod $pod -n $ns -o=jsonpath='{.spec.containers[*].name}')
  containers=($containers)
  
  if [[ "${#containers[@]}" -eq '1' ]]; then
    kubectl logs -n $ns $pod --tail=100
    echo "";echo "";
  else
    containers_list
  fi  
}

list_pods(){
  clear
  while true; do
    ns=$1
    pods_list=$(kubectl get po -n $ns --no-headers=true | grep -ivw -e "Terminating" | awk '{print NR")", $1}')

    if [[ -z "$pods_list" ]]; then
      handle_error false "No pods found in namespace $ns"
      break
    fi
  
    echo "********************************************"
    echo "Below are the list of pods present in $ns"
    echo "********************************************"
    echo "0) Exit"
    echo "$pods_list"
    echo ""
    
    read -p "Select the pod you want to check logs of : " pod_no
    echo ""
    
    pods_count=$(kubectl get po -n $ns --no-headers=true | wc -l)
    re='^[0-9]+$'
    
    if ! [[ $pod_no =~ $re ]]; then
      handle_error false "Please enter a valid number"
      continue
    fi
    
    if [[ $pod_no -eq "0" ]]; then
      clear
      break
    fi

    if ! ((pod_no <= pods_count)); then
      handle_error false "Entered number is out of range. Please enter a valid number"
      continue
    fi
    
    pod=$(echo "$pods_list" | awk -v num="$pod_no" 'NR == num {print $2}')
    pod_logs

  done
}

list_namespaces(){
  clear
  while true
  do 
    namespaces_list=$(kubectl get ns --no-headers=true | awk '{print NR")", $1}')
    echo "***********************************************************"
    echo "Below are the list of namespaces present in this K8 cluster"
    echo "***********************************************************"
    echo "0) Exit"
    echo "$namespaces_list"
    
    read -p "Enter namespace number : " ns_num
    namespaces_count=$(kubectl get ns --no-headers=true | wc -l)
    
    re='^[0-9]+$'
    
    if ! [[ $ns_num =~ $re ]]; then
        handle_error false "Please enter a valid number."
        continue
    fi
    
    if [ "$ns_num" -eq 0 ]; then
        handle_error true "Forced Exit"
        break
    fi
    
    if ! ((ns_num <= namespaces_count)); then
        handle_error false "Entered number is out of range. Please enter a valid number."
        continue
    fi
    
    ns=$(echo "$namespaces_list" | awk -v num=$ns_num ' NR == num {print $2}')
    echo "NAMESPACE SELECTED : $ns"
	
    list_pods $ns
  done
}

list_namespaces
