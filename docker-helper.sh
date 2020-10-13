#!/bin/sh

## Script to run additional docker-compose files that specify local services to build or run.
## Also can be used to pull down images from Docker Hub.

all_services="api cli processor sds"

function clean_up() {
    docker-compose down
}

## Run the specified images and perform a `docker-compose down` upon exit
function run_images() {
    cmd=""
    exitcode=0

    for service_name in "$@"; do
        cmd="${cmd} -f docker-compose.$service_name.yaml"
    done

    cmd="docker-compose -f docker-compose.yaml ${cmd} up"
    $cmd

    test_exit=$?

    if [[ $test_exit != 0 ]]; then
        exitcode=1
    fi

    trap clean_up EXIT
    exit $exitcode
}

## Rebuild the specified images
function build_images() {
    cmd=""

    ## Rebuild all services if `local` is passed
    if [[ $1 == "local" ]]; then
        cmd="docker-compose -f docker-compose.yaml -f docker-compose.local.yaml up -d --no-deps --build ${all_services}"
    else
        services=""

        for service_name in "$@"; do
            services="$service_name ${services}"
            cmd="${cmd} -f docker-compose.$service_name.yaml"
        done

        cmd="docker-compose -f docker-compose.yaml ${cmd} up -d --no-deps --build ${services}"
    fi

    $cmd
}

if [[ $1 == "--run" || $1 == "-r" ]]; then
    run_images ${@:2}
elif [[ $1 == "--build" || $1 == "-b" ]]; then
    build_images ${@:2}
else
    echo "
ERROR: $1 is an unrecognized flag.

Options:
    -r, --run <service_names>      Run Docker images. Use 'local' for all local images, or specify one or more services.
                                   No additional args wil run all images from Docker Hub (non-local).
    -b, --build <service_names>    Build Docker images. Use 'local' for all local images, or specify one or more services.
                                   No additional args wil run all images from Docker Hub (non-local).
    "
fi
