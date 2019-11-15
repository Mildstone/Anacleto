

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


SSHREMOTE_NAME="spilds1"
SSHREMOTE_HOST="spilds"
SSHREMOTE_PORT=22
SSHREMOTE_USER="rigoni"
SSHREMOTE_PEM=~/.ssh/id_rsa
SSHREMOTE_SCRIPTPATH=.ssrremote



write_config() {
 file_name=${SSHREMOTE_SCRIPTPATH}/${SSHREMOTE_NAME}.sh
 log "Writing script file in ${file_name}"
 [ -d ${SSHREMOTE_SCRIPTPATH} ] || mkdir -p ${SSHREMOTE_SCRIPTPATH}
 cat <<- _EOF_ > ${file_name}
# Docker container config
# created: $(date)
SSHREMOTE_NAME=${SSHREMOTE_NAME}
SSHREMOTE_HOST=${SSHREMOTE_HOST}
SSHREMOTE_PORT=${SSHREMOTE_PORT}
SSHREMOTE_USER=${SSHREMOTE_USER}
SSHREMOTE_PEM=${SSHREMOTE_PEM}
_EOF_
}

read_config() {
  file_name=${SSHREMOTE_SCRIPTPATH}/${SSHREMOTE_NAME}.sh
  [ -f ${file_name} ] && source ${file_name}
}


genkey() {
  pem=${1:-${SSHREMOTE_PEM:-~/.ssh/id_rsa}}
	if [ ! -f $pem ]; then
	 ssh-keygen -t rsa -b 2048 -f $1 -C "$2"
	fi
}


copyid() {
  genkey ${SSHREMOTE_PEM}
  ssh-copy-id -i ${SSHREMOTE_PEM} -p ${SSHREMOTE_PORT} -f ${SSHREMOTE_USER}@${SSHREMOTE_HOST}
}




execute()  {
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



