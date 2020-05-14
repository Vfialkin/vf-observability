Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# garantee that we deploy to mimikube
kubectl config use-context minikube

# check if its running
Write-Output "Checking kube status..."
$status= minikube status
if ($status -like '*Misconfigured*'  -Or $status -like '*Stopped*') 
{
    throw $status
    #restart kube with minikube stop; minikube start;
}

#a) update repos
helm repo add elastic https://helm.elastic.co
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update

#b) create namespace
$namespace='observability'
$namespaceLog = kubectl get namespace
if ($namespaceLog -like "*$namespace*") {Write-Output "$namespace exists"}
else {kubectl create namespace $namespace}

#c) intsalling

Write-Output "Installing elastic"
helm upgrade --install elastic-logs elastic/elasticsearch -n $namespace -f .\elastic\elastic-local.yaml

Write-Output "Installing kibana"
helm upgrade --install kibana-logs elastic/kibana -n $namespace -f .\kibana\kibana-local.yaml

Write-Output "Installing fluent-bit"
helm upgrade --install fluent-bit stable/fluent-bit -n $namespace -f .\fluentbit\fluent-bit-local.yaml

#verify and start
minikube service list
minikube service kibana-logs-kibana -n $namespace
Write-Output "Done. Might take some time for kube to download all required images"
