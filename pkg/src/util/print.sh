# shellcheck shell=bash

# @file print.sh
# @brief Prints statements that are not indented

print.die() {
	print.error "$1"
	exit 1
}

# Fatal errors are internal errors here
print.fatal() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "%11s: %s\n" "Fatal" "$1" >&2
	else
		printf "\033[0;31m%11s\033[0m %s\n" 'Fatal' "$1" >&2
	fi

	# Print stack trace
	if (( ${#FUNCNAME[@]} >> 2 )); then
	printf '%s\n' 'STACK TRACE'
		for ((i=1;i<${#FUNCNAME[@]}-1;i++)); do
		printf '%s\n' "  $i: ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}(...)"
		done
	fi

	exit 1
}

print.error() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "%11s: %s\n" "Error" "$1" >&2
	else
		printf "\033[0;31m%11s\033[0m %s\n" 'Error' "$1" >&2
	fi
}

print.warn() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "%11s: %s\n" 'Warning' "$1" >&2
	else
		printf "\033[0;33m%11s\033[0m %s\n" 'Warning' "$1" >&2
	fi
}

print.info() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "%11s: %s\n" 'Info' "$1"
	else
		printf "\033[0;32m%11s\033[0m %s\n" 'Info' "$1"
	fi
}

print.green() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "%11s: %s\n" "$1" "$2"
	else
		printf "\033[0;32m%11s\033[0m %s\n" "$1" "$2"
	fi
}

print.log(){
	local -A logformat
	local output="${LOGFORMAT}"

	logformat["%a"]=$RHOST
	logformat["%A"]=$BIND_ADDRESS
	logformat["%b"]=${RES_HEADERS["Content-Length"]}
	logformat["%m"]=$REQ_METHOD
	logformat["%q"]=$REQ_QUERY
	logformat["%t"]=$TIME_FORMATTED
	logformat["%s"]=${RES_HEADERS['status']%% *}
	logformat["%T"]=$(( $(printf '%(%s)T' -1 ) - TIME_SECONDS))
	logformat["%U"]=$REQ_URL

	local key=
	for key in "${!logformat[@]}"; do
		output="${output//"$key"/"${logformat[$key]}"}"
	done; unset -v key

	cat <<< "$output" >> "$LOGFILE"
}

