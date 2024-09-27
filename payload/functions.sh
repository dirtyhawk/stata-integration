#! /bin/sh
# shellcheck enable=require-variable-braces
prompt_msg(){
    MESSAGE=$*
    printf '\e[1;34mQuestion:\e[0m\t %b\n' "${MESSAGE}"
}
status_msg(){
    MESSAGE=$*
    printf '\e[1;32mInfo:\e[0m\t %b\n' "${MESSAGE}"
}
warning_msg(){
    MESSAGE=$*
    printf '\e[1;33mWARNING:\e[0m %b\n' "${MESSAGE}" 1>&2
}
error_msg(){
    MESSAGE=$*
    printf '\e[1;31mERROR:\e[0m\t %b\n' "${MESSAGE}" 1>&2
}
is_root () {
    return "$(id -u)"
}
has_sudo() {
    prompt=$(sudo -nv 2>&1)
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
    echo "has_sudo__pass_set"
    elif echo "${prompt}" | grep -q '^sudo:'; then
    echo "has_sudo__needs_pass"
    else
    echo "no_sudo"
    fi
}
elevate_cmd() {
    cmd=$*
    HAS_SUDO=$(has_sudo)
    case "${HAS_SUDO}" in
    has_sudo__pass_set)
        # shellcheck disable=SC2086
        sudo ${cmd}
        ;;
    has_sudo__needs_pass)
        status_msg "$(printf "Please supply your sudo password for the following command: sudo %s" "${cmd}")"
        # shellcheck disable=SC2086
        sudo ${cmd}
        ;;
    *)
        status_msg "$(printf "Please supply the root password for the following command: su -c \"%s\"" "${cmd}")"
        su -c "${cmd}"
        ;;
    esac
}
exec_depending_on_mode() {
	cmdline=$*
	if [ "${MODE}" = "system" ] ; then
		# shellcheck disable=SC2086
		elevate_cmd ${cmdline}
	else
		${cmdline}
	fi
}
