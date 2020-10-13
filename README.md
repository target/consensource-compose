# ConsenSource docker-compose

This application runs using separate Docker containers for the various components. These Docker images may be run together using the `docker-compose.yaml` file included within the repository.

## Setup

### Repo structure with Git Submodules

Each of the services required to run ConsenSource lives in it's own repo with it's own Dockerfile. In order to simplify the development process, our _docker-compose_ pattern takes an opinionated approach and assumes that the developer is using Git submodules to create a mono-repo like structure.

To get started with submodules, clone this repo with the following command:

```
$ git clone --recurse-submodules https://github.com/target/consensource-compose.git
```

If you already cloned but want submodules, run:

```
$ git submodule update --init --recursive
```

## Running ConsenSource

### With local images

If you would like to run an image that you have built locally, you need to specify the additional `docker-compose.<service-name>.yaml` file that will build and run images with the `:local` tag. For example, to run using a local build for the REST API:

```
$ docker-compose -f docker-compose.yaml -f docker-compose.api.yaml up
```

To make this simpler you can use `docker-helper.sh` with either a `--build` or `--run` flag followed by the service names. The previous command then becomes

```
$ ./docker-helper.sh --run api
```

To rebuild any local image:

```
$ ./docker-helper.sh --build <service-name>
```

To run using only locally built images:

```
$ ./docker-helper.sh --build local
```

### With Docker Hub images

To start the ConsenSource application using the latest images from Docker Hub, run the following command in the project's root directory:

```
$ ./docker-run.sh --run
```

By default, the `docker-compose.yaml` file will run containers for images with the `:latest` tag. On your first run, these will be pulled down from Docker Hub.  

To pull the most recent images from Docker Hub:

```
$ docker-compose pull --ignore-pull-failures
```

To run local images that have a `:local` tag:

```
$ ./docker-helper.sh --run <service-name>
```

To run with all local images:

```
$ ./docker-helper.sh --run local
```

### Running the UI

The UI needs to be ran separately from the compose network. Please refer to the [UI ReadMe](ui/README.md) for instructions.

### Working with Git Submodules

#### Manual Update of a Single Submodule

To update a single submodule to the latest commit in master manually, `cd subdirectory` and run normal commands such as `git fetch`, `git pull`, and `git merge origin/master`. If you commit this after updating, the submodule
will be tied to the newest commit in the remote, and will update for others when they `pull`.

#### Less Manual Update

Run `git submodule update --remote $submodule_name`. This fetches and updates.

Even more fun, run

```
git submodule foreach git pull
```

to update all submodules.

Note: The command after `foreach` can be any arbitrary shell command.

For better logs when `diff`ing, add a config: `git config --global diff.submodule log`.

[Reference](https://git-scm.com/docs/git-submodule) |
[Git Book](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
