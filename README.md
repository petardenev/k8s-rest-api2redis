# k8s Rest-Api 2 Redis example

Kubernetes ready GO Lang REST-API for querying Redis

## Install minikube

Considering the fact that the machine testing the solution will either have minikube installed OR
it will run Linux
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

## Test Dataset

```
[
    {
        "firstname": "Homer",
        "lasname": "Simpson"
    }
]
```


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
./helper.sh compose
```

## Deploy on Minikube
```
git clone https://github.com/petardenev/k8s-rest-api2redis.git
cd k8s-rest-api2redis
minikube start (you need to install minikube before)
./helper.sh deploy
```

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
GET http://{minikube-ip}:{api-port}}/api/user/Homer
Host: api.minikube
Content-Type: application/json
```
