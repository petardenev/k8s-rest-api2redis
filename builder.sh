#!/usr/bin/env bash

set -o nounset -o errexit
#set -x
# Global variables
VERSION_TAG="latest"
METHOD="POST"
PATH_TO_K8S="$PWD/k8s"

function build {
  # Using Docker MultiStage build, to make sure the build process will pass OK even if the devenv is not setup-ed properly,
  # the build process works no matter the underlying setup
  cd $PWD
  docker build . -t api:${VERSION_TAG}
}

function compose {
  # Just for testing purposes, of course, we can test on the minikube cluster, but its easier with docker-compose
  cd $PWD
  docker-compose up --build

}

function deploy {
  # Usually I prefer to use something better than bash and not to apply the manifests in the way shown below,
  # but for the sake of the task - I am doing it quick and dirty
  # Below, we imply that the developer would have used the compose to test whether the application works, before deploying to k8s
  cd $PWD
  eval $(minikube docker-env)
  docker build . -t api:latest
  cd $PATH_TO_K8S
  kubectl apply -f volumes.yaml
  kubectl apply -f redis.yaml
  kubectl apply -f api.yaml
  cd ..
}

function destroy {
  cd $PATH_TO_K8S
  kubectl delete -f volumes.yaml
  kubectl delete -f redis.yaml
  kubectl delete -f api.yaml
  cd ..
}

function test {
  # Quick and dirty testing of the app
  #
  JSON='{"firstname": "Homer", "lastname": "Simpson"}'
  if  [[ ${METHOD} == "POST" ]]; then
    curl -X ${METHOD} -H "Content-Type: application/json" --data "$JSON" "http://127.0.0.1:8088/user"
  elif  [[ ${METHOD} == "GET" ]]; then
    curl -X ${METHOD} "http://127.0.0.1:8088/user/Homer"
  fi
}

function print_usage_and_exit {
    cat <<EOF
    $(basename $0) - Build, Deploy or Test

    Use this tool to manage the k8s-rest-api2redis

    Basic usage is to evoke the script with a sub-command and options for
    that sub-command.

    Global options:

        -h, --help                      This help :)

    Subcommands:

        build                          build the application
            --version-tag <VersionTag>            The Git Tag or Branch Name, can be automatically obtained from the repository

        deploy                         Does deploy the application to a minikube cluster

        compose                        Does use the docker-compose recipe to run the application

        test                           Does execute curl requests to test the application
            --method <GETorPOST>            only GET or POST methods are available

        destroy                        Does destroy the deployment to minikube

    Examples:

        Build the service
            $(basename $0) build  --version-tag <VersionTag>

        Deploy the service
            $(basename $0) deploy

        Docker-compose recipe start
            $(basename $0) compose

        Destroy minikube cluster
            $(basename $0) destroy

EOF

    exit 2
}

 if [[ $# -gt 0 ]]; then
    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                print_usage_and_exit
                ;;
            build|deploy|compose|test|destroy)
                SUBCMD="${1}"
                shift
                ;;
            --version-tag)
                VERSION_TAG="${2}"
                shift 2
                ;;
            --method)
                METHOD="${2}"
                shift 2
                ;;
            --*)
                echo "Unknown option ${1}"
                ;;
            *)
                echo "Unknown sub-command ${1}"
                ;;
        esac
    done
else
    print_usage_and_exit
fi

case "${SUBCMD}" in
    build)
        build
        ;;
    deploy)
        deploy
        ;;
    compose)
        compose
        ;;
    test)
        test
        ;;
    destroy)
        destroy
        ;;
    *)
        echo "Missing required subcommand. "
esac
