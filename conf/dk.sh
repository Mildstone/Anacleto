#!/bin/bash

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
       -v|--verbose)      show script source script
			 -c )               reserved for Makefile operations

EOF
}

assert () {                                               
  E_PARAM_ERR=98
  E_ASSERT_FAILED=99

  if [ -z "$1" ]; then                
    return $E_PARAM_ERR 
  fi

  if [ ! $1 ]; then
    echo "Assertion failed:  \"$1\""
    echo "File \"$0\", line ${2:-$1}"  
    exit $E_ASSERT_FAILED
  fi  
}




## parse cmd parameters:
while [[ "$1" == -* ]] ; do
	case "$1" in
		-h|--help)
			print_help
			exit
			;;
		-c) # this argument is reserved for shell execution (by Makefile)
		  CMD=docker_shell
			shift
			break
			;;
		# -i)
		#   CMD=init_container
		# 	shift
		# 	break
		# 	;;
	  -v|--verbose)
			set -x
			echo "VEROBOSE dk command: $@"
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

# if no DOCKER_CONTAINER revert to normal shell 
# (this is needed for shell command within make for example,
#  but those command are not executed in container though )
[ ${DOCKER_CONTAINER} ] || { echo "CMD=${CMD}"; ${SHELL:-/bin/sh} -c $@; exit; }


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



##   ..######...#######..##....##.########....###....####.##....##.########.########.
##   .##....##.##.....##.###...##....##......##.##....##..###...##.##.......##.....##
##   .##.......##.....##.####..##....##.....##...##...##..####..##.##.......##.....##
##   .##.......##.....##.##.##.##....##....##.....##..##..##.##.##.######...########.
##   .##.......##.....##.##..####....##....#########..##..##..####.##.......##...##..
##   .##....##.##.....##.##...###....##....##.....##..##..##...###.##.......##....##.
##   ..######...#######..##....##....##....##.....##.####.##....##.########.##.....##

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
DOCKER_URL=${DOCKER_URL}
DOCKER_DOCKERFILE=${DOCKER_DOCKERFILE}
DOCKER_IMAGE_ID=$(dk_get_image_id ${DOCKER_IMAGE}; echo $_ans)
DOCKER_NETWORKS="${DOCKER_NETWORKS}"
DOCKER_PORTS="${DOCKER_PORTS}"
DOCKER_SHARES="${DOCKER_SHARES}"
DOCKER_MOUNTS="${DOCKER_MOUNTS}"
: \${DOCKER_MACHINE=${DOCKER_MACHINE}}
: \${USER=${USER}}
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

# build image from URL (either local directory or web page content)
# the image name can be a local name or any overlapping name that will 
# overload the that name for the local repository 
build() {
	[ -n "${DOCKER_IMAGE}" ] || DOCKER_IMAGE="${DOCKER_CONTAINER}_build"
	if [ -n "${DOCKER_DOCKERFILE}" ]; then
	  DOCKER_BUILD_ARGS="${DOCKER_BUILD_ARGS} -f ${DOCKER_DOCKERFILE}"
	fi
	echo docker build ${DOCKER_BUILD_ARGS} -t ${DOCKER_IMAGE} ${DOCKER_URL}
	docker build ${DOCKER_BUILD_ARGS} -t ${DOCKER_IMAGE} ${DOCKER_URL}
}


push() {	
	dk_get_container_image ${DOCKER_CONTAINER}
	if [ -n $_ans ]; then
	  if [ ${DOCKER_REGISTRY} ]; then
	    docker tag $_ans ${DOCKER_REGISTRY}/$_ans
			docker push ${DOCKER_REGISTRY}/$_ans
	  else
			echo "pushing to: ${DOCKER_IMAGE}"
			docker push $_ans
		fi
	fi
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


adduser() {
	local user_id=$(id -u ${USER})
	local user_entry=$(awk -F: "{if (\$3 == "${user_id}") {print \$0} }" /etc/passwd);
	docker exec ${INT} --user root ${DOCKER_CONTAINER} /bin/bash -l -c \
	  " id -u ${USER} 2>/dev/null || echo ${user_entry} >> /etc/passwd; "
	#
	# local group_id=$(id -g ${USER})
	#	local group_entry=$(awk -F: "{if (\$3 == "${group_id}") {print \$0} }" /etc/group);
	# docker exec ${INT} --user root ${DOCKER_CONTAINER} /bin/bash -l -c \
	#   " group_entry=\$(awk -F: \"{if (\\\$3 == \"${group_id}\") {print \\\$0} }\" /etc/group); \
	# 	  [ -n "\${group_entry}" ] || echo ${group_entry} >> /etc/group; \
	# 	"
}


# # create the volume in advance
#   $ docker volume create --driver local \
#       --opt type=none \
#       --opt device=/home/user/test \
#       --opt o=bind \
#       test_vol

#   # create on the fly with --mount
#   $ docker run -it --rm \
#     --mount type=volume,dst=/container/path,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=/home/user/test \
#     foo



# START
start() {
	if [ -n "${DOCKER_URL}" ]; then
	  echo "BUILDING |${DOCKER_URL}|"
		build
	fi
  # find if container is is registered
  dk_get_container_id ${DOCKER_CONTAINER_ID}
	if [ -z "${_ans}" ]; then
		if test -n "${DOCKER_SHARES}"; then
		 for _share in ${DOCKER_SHARES}; do
		  DOCKER_SHARES_VAR="-v ${_share} ${DOCKER_SHARES_VAR}";
		 done
		fi
    if test -n "${DOCKER_NETWORKS}"; then
		 for _n in ${DOCKER_NETWORKS}; do
		  DOCKER_NETWORKS_VAR="--network=$_n ${DOCKER_NETWORKS_VAR}";
		 done
		fi
    if test -n "${DOCKER_PORTS}"; then
		 for _n in ${DOCKER_PORTS}; do
		  DOCKER_PORTS_VAR="-p $_n ${DOCKER_PORTS_VAR}";
		 done
		fi
    if test -n "${DOCKER_MOUNTS}"; then
		 for _n in ${DOCKER_MOUNTS}; do		  
			IFS=':' read -ra _vols <<< "$_n";
			assert "${#_vols[@]} -eq 2" $LINENO
			mkdir -p ${_vols[0]}
			local _src="$(cd ${_vols[0]}; pwd)"
			local _dst="${_vols[1]}"
		  DOCKER_MOUNTS_VAR="--mount dst=$_dst,volume-driver=local,volume-opt=o=bind,volume-opt=device=$_src ${DOCKER_MOUNTS_VAR}";
		 done
		fi
	  log "Starting docker container from image ${1:-${DOCKER_IMAGE}}"
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
  						 ${DOCKER_MOUNTS_VAR} \
  						 ${DOCKER_NETWORKS_VAR} \
							 ${DOCKER_PORTS_VAR} \
							 ${DOCKER_PROFILE_VAR} \
  						 -w $(pwd) \
  						 --name ${DOCKER_CONTAINER} \
  						 ${1:-${DOCKER_IMAGE}};
		# add user
		adduser
		# copy dk.sh in container for furter operations
		docker cp ${SCRIPT_DIR}/${SCRIPTNAME} ${DOCKER_CONTAINER}:/sbin/dk.sh		
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

# CLEAN
clean() {
	dk_get_container_id ${DOCKER_CONTAINER_ID}
	if [ -n "${_ans}" ]; then
	  stop
	fi
	file_name=${DOCKER_SCRIPTPATH}/${DOCKER_CONTAINER_PREFIX}.sh
	[ -f ${file_name} ] && rm -f ${file_name} ||:
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



shell() {
  execute ${DOCKER_SHELL} $@
}


##    .##.....##....###.....######..##.....##.####.##....##.########
##    .###...###...##.##...##....##.##.....##..##..###...##.##......
##    .####.####..##...##..##.......##.....##..##..####..##.##......
##    .##.###.##.##.....##.##.......#########..##..##.##.##.######..
##    .##.....##.#########.##.......##.....##..##..##..####.##......
##    .##.....##.##.....##.##....##.##.....##..##..##...###.##......
##    .##.....##.##.....##..######..##.....##.####.##....##.########

if [ -n ${MACHINE_NAME} ]; then
  ## ENV
  ## NEEDS: abs_top_builddir abs_top_srcdir
  : ${abs_top_srcdir:? "error abs_top_srcdir not defined"}
  : ${abs_top_builddir:? "error abs_top_builddir not defined"}
  : ${DOCKER_MACHINE_SORAGE_PATH=${abs_top_builddir}/conf/.docker}

  clean_dir () {
  	cd $1 && pwd
  }
  
  abs_top_srcdir=$(clean_dir ${abs_top_srcdir}; )
  abs_top_builddir=$(clean_dir ${abs_top_builddir}; )
fi

machine() {
	: ${MACHINE_NAME:? "error no MACHINE_NAME defined"}
	docker-machine -s ${DOCKER_MACHINE_SORAGE_PATH} $@
}

machine_ssh() {
	: ${MACHINE_NAME:? "error no MACHINE_NAME defined"}
	machine ssh ${MACHINE_NAME} $@
}

machine_status() {	
	: ${MACHINE_NAME:? "error no MACHINE_NAME defined"}
	machine ls -f '{{.State}}' --filter name=${MACHINE_NAME}
}

# machine-create: ##@docker_machine create new machine
machine_create() {    
	: ${MACHINE_NAME:? "error no MACHINE_NAME defined"}
  local _driver=${DOCKER_MACHINE_DRIVER:-virtualbox}
  local _swarm_token=$(docker swarm join-token worker -q 2>/dev/null)
  local _swarm=${_swarm_token:+ --swarm}
  
  local _driver_args="--driver $_driver"
  if [ $_driver = "virtualbox" ]; then
			local _iso=${DOCKER_MACHINE_ISO}
      [ $_iso ] && _driver_args="$_driver_args --virtualbox-boot2docker-url $_iso"
  fi
  # create storage path
  if [ ! -d ${DOCKER_MACHINE_SORAGE_PATH} ]; then
      mkdir -p ${DOCKER_MACHINE_SORAGE_PATH};
  fi
	if [ ! "$(machine_status)" = "Running" ]; then
  	machine create $_driver_args ${DOCKER_MACHINE_ARGS} $_swarm ${MACHINE_NAME}
	fi
}


machine_rm() {
	${MACHINE_NAME:? "error no MACHINE_NAME defined"}
	machine rm ${MACHINE_NAME}
}

machine_mount() {
	: ${MACHINE_NAME:? "error no MACHINE_NAME defined"}
   test "$(machine_status)" = "Running" && _machine=${MACHINE_NAME}
	: ${_machine:? "any configured machine could be found"}
   _ip=$(machine inspect -f '{{.Driver.IPAddress}}' $_machine)
   _port=$(machine inspect -f '{{.Driver.SSHPort}}' $_machine)
   _user=$(machine inspect -f '{{.Driver.SSHUser}}' $_machine)
   _key=$(machine inspect -f '{{.Driver.SSHKeyPath}}' $_machine)
	# reverse_mount () {
	# 	##
	# 	## linux - how to mount local directory to remote like sshfs? - Super User 
	# 	## https://superuser.com/questions/616182/how-to-mount-local-directory-to-remote-like-sshfs
	# 	##		
	# 	local _local_port="22"
	# 	local _forward_port="10000" # work on this !!
	# 	local _remote_port="xxx"
	# 	local _local_ssh="-p $_forward_port ${USER}@$_local_addr"
	# 	local _remote_ssh="-p $_remote_port ${USER}@$_remote_addr"
	# 	local _sshfs_option="-o NoHostAuthenticationForLocalhost=yes"
	# 	## options:
	# 	##       -v Verbose 
	# 	##       -X X11 forwarding
	# 	##       -t pseudo-terminal for an interactive shell
	# 	##
	# 	#ssh -X -t $REMOTE_SSH -R $FORWARD_PORT:localhost:$LOCAL_PORT \
	# 	#"source /etc/profile; mkdir -p $REMOTE_DIR; \
	# 	# sshfs $SSHFS_OPTION $LOCAL_SSH:$LOCAL_DIR $REMOTE_DIR; bash; \			 
	# 	# umount $REMOTE_DIR; rm -r $REMOTE_DIR"
	# 	machine-ssh tce-load -w -i sshfs-fuse
	# 	machine-ssh mkdir -p $1;
	# 	sshfs $_sshfs_option 
	#   # groupadd -g ${user_group} ${USER} 2>/dev/null; \
	#   # useradd  -d ${user_home} -u ${user_id} -g ${user_group} ${USER} 2>/dev/null; \
	# }
   # mount() { sshfs -d $1 $_user@$_ip:/$1; }
   # mount ${abs_top_srcdir}
   # mount ${abs_top_builddir}
	echo "This wont work unless reverse sshfs is performed"
}   

machine_ls() {
	: ${MACHINE_NAME:? "error no MACHINE_NAME defined"}
	machine ls
}


machine_init() {
	: ${MACHINE_NAME:? "error no MACHINE_NAME defined"}
	# set -e
	machine_create && eval $(machine env ${DOCKER_MACHINE})

}


## ////////////////////////////////////////////////////////////////////////////////
## //  MAIN  //////////////////////////////////////////////////////////////////////
## ////////////////////////////////////////////////////////////////////////////////

# ALWAYS READ CONFIGURATION BACK (IF EXISTS)
read_config


# MAIN [TO FIX]
# if [ x$CMD = x"shell" ]; then
#   execute ${DOCKER_SHELL} -c "$@"
# else
#   $@
# fi

case ${CMD} in
	docker_shell)
    # start machine env if exists
    [ ${DOCKER_MACHINE} ] && machine_init
		execute ${DOCKER_SHELL} -c "$@"
		;;	
	*)
		$@
		;;
esac





