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

### Deploy on Minikube
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
