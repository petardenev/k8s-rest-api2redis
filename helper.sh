#!/usr/bin/env bash

set -o nounset -o errexit
#set -x
# Global variables
VERSION_TAG="latest"
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
  docker-compose up -d --build

}

function deploy {
  # Usually I prefer to use something better than bash and not to apply the manifests in the way shown below,
  # but for the sake of the task - I am doing it quick and dirty
  # Below, we imply that the developer would have used the compose to test whether the application works, before deploying to k8s
  cd $PATH_TO_K8S
  kubectl create -f namespaces.yaml
  kubectl create -f volumes.yaml
  kubectl create -f ingress.yaml
  kubectl create -f ingress-controller.yaml
  kubectl create -f redis.yaml
  kubectl create -f api.yaml
  cd ..
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
            --version-tag <VersionTag>            The Git Tag or Branch Name, can be automatically obtained from the repository

        compose                        Does use the docker-compose recipe to run the application
            --version-tag <VersionTag>           The Git Tag or Branch Name, can be automatically obtained from the repository

    Examples:

        Build the service
            $(basename $0) build  --version-tag <VersionTag>

        Deploy the service
            $(basename $0) deploy  --version-tag <VersionTag>

        Docker-compose recipe start
            $(basename $0) compose --version-tag <VersionTag>
EOF

    exit 2
}

 if [[ $# -gt 0 ]]; then
    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                print_usage_and_exit
                ;;
            build|deploy|compose)
                SUBCMD="${1}"
                shift
                ;;
                ;;
            --version-tag)
                VERSION_TAG="${2}"
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
    *)
        echo "Missing required subcommand. "
esac
