## Installing to Minikube


##### Install:
- Run in powershell:
```
 .\DeployToMinikube.ps1
```

Thats it ;)

######  Optional: Setup default dashboard In Kibana UI :

Go to: 

```Kibana=> Managment=> Kibana Saved Objects=> Import``` 

choose <strong>defaultLogSettings.ndjson</strong> from folder:

```
dashboardSettings
```

If you are asked to setup index provide <strong>logstash-*</strong> and <strong>@timestamp</strong> for for TimeStamp

## Installing to Dev/QA Cluster

Create namespace
```
kubectl create namespace observability
```

#### Elastic peristent volumes
Elastic requires PersistentVolumes for storage. Local storage cannot be dynamically provisioned by k8 so PVs must be created manually. 
Check if there's a local-storage storage class
```
kubectl get sc
```

If there's none create storage and then run
```
kubectl apply -f .\PersistentVolumes.yaml  --namespace observability
```

#### Update repo
```
helm repo add elastic https://helm.elastic.co
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update
```

#### Instal with Helm
```
helm upgrade --install elastic-logs elastic/elasticsearch -n observability -f .\elastic\elastic-dev.yaml
helm upgrade --install kibana-logs elastic/kibana -n observability -f .\kibana\kibana-dev.yaml 
helm upgrade --install fluent-bit stable/fluent-bit -n observability -f .\fluentbit\fluent-bit-dev.yaml
```
#
## Configuration:

##### NOTES:
Uninstall does not remove existing Persistent Volumes or Persistent Volume Claims. 

Node port services are deployed to ports 30562, 30922. Both ports can be customized from helm charts
http://ip:30562/
http://ip::30922/


#### Log size in minikube
By default logs are not rotated but you can setup log rotation by limiting 10mb size per log and 2 files max per service
https://docs.docker.com/config/containers/logging/configure/
```
 minikube ssh 
 sudo sh -c 'echo "{\"log-driver\":\"json-file\",  \"log-opts\": {\"max-size\":\"10m\", \"max-file\": \"2\"}}"  > /etc/docker/daemon.json'
 cat /etc/docker/daemon.json
```

#### Clean up logs in minikube:
```
minikube ssh "sudo sh -c 'truncate -s 0 /var/lib/docker/containers/*/*-json.log'"
```


#### Problems:
  Time out of sync in minikube after sleep 
  https://github.com/kubernetes/minikube/issues/1378  
```
  ssh -i ~/.minikube/machines/minikube/id_rsa docker@$(minikube ip) "docker run --rm --privileged --pid=host alpine nsenter -t 1 -m -u -n -i date -u $(date -u +%m%d%H%M%Y)"
```
