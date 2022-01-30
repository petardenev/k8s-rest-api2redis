# k8s Rest-Api 2 Redis example

Kubernetes ready GO Lang REST-API for querying Redis

## Prerequisite

### Install minikube

Considering the fact that the machine testing the solution will either have minikube installed OR
it will run Linux
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### Install helm

```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

## Application Description

The application is a REST-API done in Golang to provide way to access RedisDb
There is only one endpoint available `/user`

## Local Build and [Bitbucket Pipelines](https://bitbucket.org/product/features/pipelines) CI implementation

Using the `builder.sh` script, the developer can build the application for testing it locally,
the same `builder.sh` is used from Bitbucket to build the application.
This way the whole build process is unified in a way that the behavior is the same no matter
whether you're building the app locally or in the CI

### Build the application locally
```
git clone https://github.com/petardenev/k8s-rest-api2redis.git
cd k8s-rest-api2redis
./builder.sh build --version-tag v0.01a
```

### Run the application with docker-compose
```
git clone https://github.com/petardenev/k8s-rest-api2redis.git
cd k8s-rest-api2redis
./builder.sh compose
```

### How to validate the application functionalities?
 1. Run it with the `./builder.sh compose`
 2. Open another terminal and navigate to the directory where you've cloned the Repository
 3. In the new terminal run `./builder.sh test --method POST` this will add test data
 4. In the same terminal run `./builder.sh test --method GET` to verify the results

## Enable Metrics API and add monitoring services to the stack
 The manual below contains information how to enable the Kubernetes Metrics Api
 and also deploy Loki Stack (Loki, Promtail, Grafana, Prometheus).

```
cd k8s-rest-api2redis/monitoring
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server
helm upgrade --install loki grafana/loki-stack  --set grafana.enabled=true,prometheus.enabled=true,prometheus.alertmanager.persistentVolume.enabled=false,prometheus.server.persistentVolume.enabled=false

```

## Deploy on Minikube
```
git clone https://github.com/petardenev/k8s-rest-api2redis.git
cd k8s-rest-api2redis
minikube start (you need to install minikube before)
./builder.sh deploy
```

## Test

```
// create
Post http://{minikube-ip}:{api-port}}/user
Host: minikube
Content-Type: application/json
{
  "firstname": "Homer",
  "lastname": "Simpson"
}
```

```
// get
GET http://{minikube-ip}:{api-port}}/user/Homer
Host: minikube
Content-Type: application/json
```
