#!/bin/sh

## Script to run additional docker-compose files that specify local services to build or run
## Usage examples:
##   - ./docker-helper.sh --run (will run with all images from Docker Hub)
##   - ./docker-helper.sh --build (will build images from Docker Hub)
##   - ./docker-helper.sh --build api
##   - ./docker-helper.sh --run api processor
##   - ./docker-helper.sh --build local (will rebuild all images)
##   - ./docker-helper.sh --run local (will run with all local images)

cmd_base="docker-compose -f docker-compose.yaml"
cmd_extra=""

services=""
all_services="api cli processor sds ui"

## Run the specified images and perform a `docker-compose down` upon exit
function run_containers() {
    exitcode=0

    cmd="${cmd_base}${cmd_extra} up"
    $cmd

    test_exit=$?

    if [[ $test_exit != 0 ]]; then
        exitcode=1
    fi

    trap docker-compose down EXIT
    exit $exitcode
}

## Rebuild the specified images
function build_containers() {
    cmd="${cmd_base}${cmd_extra} up -d --no-deps --build"

    ## Rebuild all services if `local` is passed
    if [ $services == "local" ]; then
        cmd="$cmd ${all_services}"
    else
        cmd="$cmd ${services}"
    fi

    $cmd
}

for service_name in "${@:2}"; do ## Skip first arg since that is either `--build` or `--run`
    services="$service_name ${services}"
    cmd_extra="${cmd_extra} -f docker-compose.$service_name.yaml"
done

if [ "$1" == "--run" ]; then
    run_containers
elif [ "$1" == "--build" ]; then
    build_containers
else
    echo 'ERROR: $1 is an unrecognized flag - use either --run or --build'
fi
