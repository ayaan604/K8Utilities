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

logs_banner(){
  start_end=$1
  
  if [[ $start_end -eq "1" ]]; then
     echo "******************************LOGS START*******************************************"
  else
     echo "******************************LOGS END*********************************************"
  fi
}

tail_100_lines(){
  if [[ -z $container ]]; then
    logs_banner 1
    kubectl logs -n $ns $pod --tail=100
    logs_banner 0
  else
    logs_banner 1
    kubectl logs -n $ns $pod -c $container --tail=100
    logs_banner 0
  fi
}

live_tail_logs(){
  if [[ -z $container ]]; then
    logs_banner 1
    kubectl logs -n $ns $pod -f
    logs_banner 0
  else
    logs_banner 1
    kubectl logs -n $ns $pod -c $container -f
    logs_banner 0
  fi
}

print_logs(){
  if [[ -z $container ]]; then
    logs_banner 1
    kubectl logs -n $ns $pod
    logs_banner 0
  else
    logs_banner 1
    kubectl logs -n $ns $pod -c $container
    logs_banner 0
  fi
}

search_logs(){
  echo ""
  read -p "Enter the search pattern you want to search the logs against : " pattern
  
  if [[ -z $container ]]; then 
    logs_banner 1
    kubectl logs -n $ns $pod | grep $pattern -i
    logs_banner 0
  else
    logs_banner 1
    kubectl logs -n $ns $pod -c $container | grep $pattern -i
    logs_banner 0
  fi
}

advanced_menu(){
  echo "Do you want to go to advanced options ?"
  echo "0. Exit"
  echo "1. Advanced"

  read -p "Enter your option : " option
  if [[ $option -eq "0" ]]; then
     return 0
  fi

  clear
  while true; do
    echo "This is the advanced menu. Choose your option of how you want to view logs"
    echo "0 : Exit"
    echo "1 : Tail last 100 lines"
    echo "2 : Live tail logs (would require ctrl+F to return to terminal)"
    echo "3 : Print full logs"
    echo "4 : Search logs with search pattern"
    echo ""
    read -p "Enter your option : " choice
    
    if [[ $choice -eq "0" ]]; then
       break
    fi
    
    case $choice in 
        0) return 0 ;;
        1) tail_100_lines ;;
        2) live_tail_logs ;;
        3) print_logs ;;
        4) search_logs ;;  
    esac
    
    echo ""; echo "";
  done
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
    
    tail_100_lines
    advanced_menu
	container=""
    echo "";echo "";
  done
}

pod_logs(){
  readarray -t containers < <(kubectl get pod $pod -n $ns -o=jsonpath='{.spec.containers[*].name}')
  containers=($containers)
  
  if [[ "${#containers[@]}" -eq '1' ]]; then
    tail_100_lines
    advanced_menu
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
