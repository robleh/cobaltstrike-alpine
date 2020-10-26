#!/usr/bin/zsh

if [[ -z "$XDG_DATA_HOME" ]]; then
    COBALT_MOUNT="$HOME$"/.cobaltstrike
else
    COBALT_MOUNT="$XDG_DATA_HOME"/cobaltstrike
fi

mkdir -p $COBALT_MOUNT

function usage() {
	cat <<-EOF
USAGE: $FUNCNAME [COMMAND] [OPTIONS]

COMMANDS

      help   display this message
      logs   follow the team server logs
      ports  display the container's port mappings
      ps     display the container's process tree
      shell  execute container shell
      status display container status
      stop   stop container 
	EOF
}

function cobalt() {
    if docker container inspect cobalt > /dev/null 2>&1; then
        case $1 in
            "help")   usage ;;
            "logs")   docker logs -f cobalt ;;
            "ports")  docker container port cobalt ;;
            "ps")     docker container top cobalt "${@:2}" ;;
            "shell")  docker exec -it cobalt /bin/sh ;;
            "status") docker container ls --filter name=cobalt ;;
            "stop")   docker stop cobalt ;;
            *)        usage ;;
        esac
    else
        echo -e "\x1B[01;34m[*]\x1B[0m Starting team server detach with ^P^Q"
        docker run -it \
            --name cobalt \
            --rm \
            -v "$COBALT_MOUNT":/mnt \
            -p 50050:50050 \
            -p 443:443 \
            -p 80:80 \
            cobaltstrike \
            $@
    fi
}

cobalt "$@"
