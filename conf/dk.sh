


# //////////////////////////////////////////////////////////////////////////// #
# // ARGS PARSE ////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

SCRIPTNAME=$(basename "$0")
SCRIPT_DIR=$(dirname "$0")

log() {
 >&2 echo " |$_err $1"
}

print_help() {
cat << EOF

Usage: $SCRIPTNAME [options] [commands]

       options
       -------
       -h|--help)         get this help
       -C|--config)       set distribution config file
       -v|--verbose)      show script source script
			 -c )               reserved for Makefile operations

EOF
}

## parse cmd parameters:
while [[ "$1" == -* ]] ; do
	case "$1" in
		-h|--help)
			print_help
			exit
			;;
		-c) # this argument is reserved for shell execution (by Makefile)
		  CMD=shell
			shift
			break
			;;
		-C|--config)
		  CONFIG_FILE=$2
			shift 2
			;;
	  -v|--verbose)
		  set -o verbose
			shift
			;;
		--)
			shift
			break
			;;
		*)
		  break
			;;
	esac
done

if [ $# -lt 1 ] ; then
	echo "Incorrect parameters. Use --help for usage instructions."
	exit 1
fi

# evaluate config file
#if [ -f ${CONFIG_FILE} ]; then
# source ${CONFIG_FILE}
#fi



## ////////////////////////////////////////////////////////////////////////////////
## //  VARIABLES  /////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////

# return a unique name containing the md5sum of the current absolute path
get_md5_container() {
  _ans="$1_$(echo $(pwd) | md5sum | awk '{print $1}')"
	[ -n "$2" ] && eval $2="$_ans"
}


DOCKER_BIN=${DOCKER_BIN:-docker}
DOCKER_SCRIPTPATH=${DOCKER_SCRIPTPATH:-.docker-build}

# append md5 to docker container
DOCKER_CONTAINER_PREFIX=${DOCKER_CONTAINER}
DOCKER_CONTAINER=$(get_md5_container ${DOCKER_CONTAINER}; echo $_ans)
DOCKER_ENTRYPOINT=${DOCKER_ENTRYPOINT:-/bin/sh}
DOCKER_SHELL=${DOCKER_SHELL:-/bin/sh}

# CONSTRUCTED VARIABLES
[ -t 7 -o -t 0 ] && INT=-ti || unset INT
user_entry=$(awk -F: "{if (\$1 == "${USER}") {print \$0} }" /etc/passwd)
user_id=$(id -u)
user_group=$(id -g)
user_home=${HOME}




## ////////////////////////////////////////////////////////////////////////////////
## //  FUNCTIONS  /////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////



write_config() {
  file_name=${DOCKER_SCRIPTPATH}/${DOCKER_CONTAINER_PREFIX}.sh
	log "Writing script file in ${file_name}"
	[ -d ${DOCKER_SCRIPTPATH} ] || mkdir -p ${DOCKER_SCRIPTPATH}
	cat <<- _EOF_ > ${file_name}
# Docker container config
# created: $(date)
DOCKER_CONTAINER=${DOCKER_CONTAINER}
DOCKER_CONTAINER_ID=$(dk_get_container_id ${DOCKER_CONTAINER}; echo $_ans)
DOCKER_IMAGE=${DOCKER_IMAGE}
DOCKER_IMAGE_ID=$(dk_get_image_id ${DOCKER_IMAGE}; echo $_ans)
USER=${USER}
user_id=${user_id}
user_group=${user_group}
user_home=${user_home}
_EOF_
}

read_config() {
  file_name=${DOCKER_SCRIPTPATH}/${DOCKER_CONTAINER_PREFIX}.sh
	[ -f ${file_name} ] && source ${file_name}
}



# dk_test_status [cnt_name] [status]
# status =  created, restarting, running, paused, exited
dk_test_status() {
  cnt_id=$(docker ps -a -f name=$1 -q)
  cnt_st=$(docker ps -a -f name=$1 -f status=$2 -q)
	[ x"${cnt_id}" = x"${cnt_st}" ] && return 0 || return 1
}

# dk_get_status [cnt_name] [ans]
# return readable status of container either in _ans or $2
dk_get_status() {
  _ans="unhandled"
	$(dk_test_status $1 created) && _ans="created"
	$(dk_test_status $1 running) && _ans="running"
	$(dk_test_status $1 restarting) && _ans="restarting"
	$(dk_test_status $1 paused) && _ans="paused"
	$(dk_test_status $1 exited) && _ans="exited"
  [ -n "$2" ] && eval $2="$_ans"
}

# dk_get_image_id [image] [ans]
# return image id from name either in _ans or $2
dk_get_image_id() {
  _ans=$(docker images -a | awk -v _img=$1 '{if ($1 ":" $2 == _img) {print $3}}' )
 [ -n "$2" ] && eval $2="$_ans"
}

# dk_get_container_id [cnt_name] [ans]
# return container id from name either in _ans or $2
dk_get_container_id() {
  unset _ans
  [ -n "$1" ] && _ans=$(docker ps -a -f name=$1 -q)
  [ -n "$_ans" ] || _ans=$(docker ps -a -f id=$1 -q)
	[ -n "$2" ] && eval $2="$_ans"
}

# dk_get_container_image [cnt_name] [ans]
# return container image
dk_get_container_image() {
  _ans=$(docker inspect --format='{{.Config.Image}}' $1)
	[ -n "$2" ] && eval $2="$_ans"
}

# dk_image_exist [image]
# test if image exists
dk_image_exist() {
  _ans=$(docker images -a -q $1 )
  [ -n "$_ans" ] && return 0 || return 1
}

# START
start() {
  # find if container is is registered
  dk_get_container_id ${DOCKER_CONTAINER_ID}
	if [ -z "${_ans}" ]; then
	  log "Starting docker container from image"
  	docker run -d ${INT} --entrypoint=${DOCKER_ENTRYPOINT} \
  						 -e USER=${USER} \
  						 -e DISPLAY=${DISPLAY} \
  						 -e LANG=${LANG} \
  						 -v /tmp/.X11-unix:/tmp/.X11-unix \
  						 -v /etc/resolv.conf:/etc/resolv.conf \
  						 -v ${abs_srcdir}:${abs_srcdir} \
  						 -v ${user_home}:${user_home} \
  						 -v $(pwd):$(pwd) \
  						 -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  						 --tmpfs /run --tmpfs /run/lock \
  						 --cap-add=SYS_ADMIN \
  						 ${DOCKER_SHARES_VAR} \
  						 ${DOCKER_NETWORKS_VAR} \
  						 ${DOCKER_PROFILE_VAR} \
  						 -w $(pwd) \
  						 --name ${DOCKER_CONTAINER} \
  						 ${1:-${DOCKER_IMAGE}};
    docker exec --user root ${DOCKER_CONTAINER} \
    				 ${DOCKER_SHELL} -c " \
    					 groupadd -g ${user_group} ${USER} 2>/dev/null; \
    					 useradd  -d ${user_home} -u ${user_id} -g ${user_group} ${USER} 2>/dev/null; \
    				 ";
		write_config
		read_config
  fi
	dk_get_container_id ${DOCKER_CONTAINER}
	if [ "$_ans" != "${DOCKER_CONTAINER_ID}" ]; then
	  log "Error: the container id does not match with existing one"
		return 1
	fi
	dk_get_status ${DOCKER_CONTAINER}
	if [ "$_ans" = "paused" ]; then
	  log "Try to resume docker container from pause"
	  docker unpause ${DOCKER_CONTAINER}
	elif [ "$_ans" = "exited" ]; then
	  log "Try to resume docker container from exit status"
		docker restart ${DOCKER_CONTAINER}
	fi
	_err=$?
	return $_err
}


# STOP
stop()  {
  log "Stopping container ${DOCKER_CONTAINER}"
  docker rm -f ${DOCKER_CONTAINER}
}

pause()  {
  log "Pauing container ${DOCKER_CONTAINER}"
  docker pause ${DOCKER_CONTAINER}
}

# RESTART
restart()  {
  log "Restating container ${DOCKER_CONTAINER}"
  docker restart ${DOCKER_CONTAINER}
}


execute()  {
  dk_get_status ${DOCKER_CONTAINER}
  [ $_ans = "running" ] || start ${DOCKER_IMAGE}
  M_ENV="$(export -p | awk '{printf("%s; ",$0)}')"
  # xhost local:andrea > /dev/null
  log "Docker: Entering container ${DOCKER_CONTAINER} ";
  quoted_args="$(printf " %q" "$@")"
  if [ -n "${MAKESHELL}" ]; then
    ${MAKESHELL} ${quoted_args};
  else
    docker exec ${INT} --user ${USER} ${DOCKER_CONTAINER} /bin/bash -l -c \
		 "save_path=\$PATH; $M_ENV \
		  export PATH=\$save_path; \
			cd $(pwd); \
			export MAKESHELL=${DOCKER_SHELL}; \
			${quoted_args}";
  fi
}


shell() {
  execute ${DOCKER_SHELL} $@
}


## ////////////////////////////////////////////////////////////////////////////////
## //  MAIN  //////////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////

# READ CONFIGURATION BACK (IF EXISTS)
read_config

# MAIN [TO FIX]
if [ x$CMD = x"shell" ]; then
  execute ${DOCKER_SHELL} -c "$@"
else
  $@
fi



