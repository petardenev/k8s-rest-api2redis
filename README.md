# k8s Rest-Api 2 Redis example

## Simply build the application
```
git clone https://github.com/petardenev/k8s-rest-api2redis.git
cd k8s-rest-api2redis
./helper.sh build --version-tag v0.01a
```

## Test with docker-compose
```
git clone https://github.com/petardenev/k8s-rest-api2redis.git
cd k8s-rest-api2redis
./helper.sh compose --version-tag v0.01a
```

## Deploy on Minikube
```
git clone https://github.com/petardenev/k8s-rest-api2redis.git
cd k8s-rest-api2redis
minikube start (you need to install minikube before)
./helper.sh deploy --version-tag v0.01a
```

Because we are using the local Minikube cluster, it is not possible to expose the Ingress Controller
as a 'LoadBalancer' Service(usually you should) on your cloud provider.

In order to access the api via Ingress, you have to run:
```
kubectl describe svc --namespace=kube-system traefik-ingress-service
```
you need to find the exposed port, for example. 31321, use this port as {api-port}

## Test

```
// create
Post http://{minikube-ip}:{api-port}}/api/user
Host: api.minikube
Content-Type: application/json
{
  "firstname": "Homer",
  "lastname": "Simpson"
}
```

```
// get
GET http://{minikube-ip}:{api-port}}/api/user/1
Host: api.minikube
Content-Type: application/json
```
