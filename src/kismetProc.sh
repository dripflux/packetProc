#!/usr/bin/env bash


## NAME
##	kismetProc.sh  Common Kismet use cases
##
## SYNOPSIS
##	kismetProc.sh help [search_term]
##	kismetProc.sh info
##
##	kismetProc.sh cap [interface_hints]...
##
##	kismetProc.sh shutdown
##
## DESCRIPTION
##	...
##
##	Subcommands:
##
##	help  (base subcommand) Display help message, supports single term filtering.
##
##	ls, list  (base subcommand) Display non-base subcommands.
##
##	manual  (base subcommand) Display this manual.
##
## 	...
##
## SCHEMAS:
##	...
##
##	usbNICmap.sh  ...
##		...
##
## EXIT STATUS
##	0  : (normal) On success
##	1+ : ERROR
##	2  : ERROR: Invalid usage
##
## DEPENDENCIES
##	basename(1) : POSIX basename
##	cat(1)      : POSIX cat
##	cut(1)      : POSIX cut
##	echo(0|1)   : Builtin or POSIX echo
##	egrep(1)    : POSIX egrep
##	grep(1)     : POSIX grep
##	kismet(1)   : https://www.kismetwireless.net/
##	less(1)     : GNU (common UNIX) less
##	tr(1)       : POSIX tr
##	tshark(1)   : https://tshark.dev/
##	wget(1)     : GNU (common UNIX) wget


# Save script name
SELF="${0}"

# Source required libraries
source usbNICmap.sh


main () {
	# Description: Main control flow
	# Arguments:
	#   ${1}  : Subcommand
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	subcommand="${1}"
	shift
	set_up_environment
	# Core actions
	case ${subcommand} in
		help )       # (base subcommand) Display this help message, supports single term filtering
			searchTerm="${1}"
			shift
			usage "${searchTerm}"
			;;
		ls | list )  # (base subcommand) List non-base subcommands
			list_non_base_subcommands
			;;
		manual )     # (base subcommand) Display full manual
			manual
			;;
		info )       # (base subcommand) Display configuration and version information
			display_info
			;;
		cap )       # Use Kismet to capture based on source (interface) hints...
			capture_kismet_source_hints "${@}"
			;;
		pcap )      # Stream packets from Kismet, store as batch pcapngs
			stream_kismet_pcap "${@}"
			;;
		shutdown )  # Gracefully shutdown Kismet
			shutdown_kismet
			;;
		trim )      # [FUTURE] Delete empty (no packets) Kismet DBs
			:
			;;
		* )
			# Default: Blank or unknown subcommand, report error if unknown subcommand
			# Note: Lack of comment on same line as case, default action will not be displayed by usage or list subcommand
			usage
			if [[ -n "${subcommand}" ]] ; then
				exit_error "ERROR: Unknown subcommand: ${subcommand}" 2
			fi
			;;
	esac
}


usage () {
	# Description: Generate and display usage
	# References: Albing, C., JP Vossen. bash Idioms. O'Reilly. 2022.
	# Arguments:
	#   ${1} : (Optional) Search term
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	searchTerm="${1}"
	shift
	# Core actions
	(
		echo $( basename "${SELF}" ) 'Usage:'
		egrep '\)[[:space:]]+# ' "${SELF}" | tr -s '\t'
	) | grep "${searchTerm:-.}" | less
}


manual () {
	# Description: Display full manual
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	:
	# Core actions
	grep '[#][#]' "${SELF}" | less
}


error_exit () {
	# Description: Output ${1} (error message) to stderr and exit with ${2} (error status).
	# Arguments:
	#   ${1} : Error message to write
	#   ${2} : (Optional) Error status to exit with
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	errorStatus=1
	errorMessage="${1}"
	shift
	# Core actions
	echo "${errorMessage}" >&2
	if [[ -n "${1}" ]] ; then
		errorStatus="${1}"
	fi
	clean_up_artifacts
	exit "${errorStatus}"
}


report_warning () {
	# Description: Output ${1} (warning message) to stderr, but DO NOT exit.
	# Arguments:
	#   ${1} : Warning message to write
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	warningMessage="${1}"
	shift
	# Core actions
	echo "${warningMessage}" >&2
}

list_non_base_subcommands () {
	# Description: Generate and display list of non-base subcommands
	# References: Albing, C., JP Vossen. bash Idioms. O'Reilly. 2022.
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	:
	# Core actions
	(
		echo $( basename "${SELF}" ) 'Subcommands:'
		egrep '\)[[:space:]]+# ' "${SELF}" | tr -d '\t'
	) | grep -v 'base[ ]subcommand' | less
}

set_up_environment () {
	# Description: Set up environment
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	:
	# Core actions
	if [[ -z "${TMPDIR}" ]] ; then
		TMPDIR='/tmp/'
	fi
}

display_info () {
	# Description: Display configuration and version information
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	:
	# Core actions
	kismet --version
}

capture_kismet_source_hints () {
	# Description: Use Kismet to capture based on source (interface) hints
	# Arguments:
	#   ${1}+ : Interface hints
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	captureArgStr=''
	# Core Actions
	# Derive Kismet capture args based on hints
	captureArgStr=$( build_capture_arg_str_from_interface_hints "${@}" )
	# Call common Kismet with capture arg string
	kismet_common_capture "${captureArgStr}"
}

build_capture_arg_str_from_interface_hints () {
	# Description: Build Kismet capture arguments string based on interface hints
	# Arguments:
	#   ${@} : Interface hints
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	wholeCaptureArgStr=''
	# Core actions
	for hint in "${@}" ; do
		partArgStr=$( derive_capture_arg_str_from_hint "${hint}" )
		if [[ -n "${partArgStr}" ]] ; then
			wholeCaptureArgStr="${wholeCaptureArgStr} ${partArgStr}"
		fi
	done
	echo ${wholeCaptureArgStr}
}

derive_capture_arg_str_from_hint () {
	# Description: Derive Kismet capture argument string based on interface hint.
	# Pass unknown hint unaltered as command line argument.
	# Argument:
	#   ${1} : Hint
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	hint="${1}"
	shift
	derivedArgStr="${hint}"
	# Core actions
	# Subprocess try hack
	nicMACaddr=$( echo ${nicMACaddrMap[x_${hint}]} )
	if [[ -n "${nicMACaddr}" ]] ; then
		argSuffix=${kismetMap[x_${hint}]}
		derivedArgStr="-c ${usbPrefix}${nicMACaddr}${argSuffix}"
	fi
	echo "${derivedArgStr}"
}

kismet_common_capture () {
	# Description: Call Kismet using common configuration capturing on ${1} (capture string).
	#  An empty capture string (no argument), will start Kismet without capturing on an interface.
	# Arguments:
	#   ${1} : Complete capture string
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	baseArgStr='--no-ncurses -s'
	captureArgStr="${1}"
	shift
	# Core actions
	commonArgStr="${baseArgStr}"
	kismetFullArgs="${commonArgStr} ${captureArgStr}"
	kismet ${kismetFullArgs} &
}

stream_kismet_pcap () {
	# Description: ...
	# Arguments:
	#   ${1} : ...
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	:
	# Core actions
	get_packet_stream &
	convert_packet_stream_to_ring_buffer_pcapng &
}

extract_kismet_creds () {
	# Desciription: Extract Kismet Web API credentials from kismet_httpd.conf
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	credentialsFile="${HOME}/.kismet/kismet_httpd.conf"
	# Core actions
	kismetUsername=$( cat "${credentialsFile}" | grep httpd_username | cut -d '=' -f 2 )
	kismetPassword=$( cat "${credentialsFile}" | grep httpd_password | cut -d '=' -f 2 )
}

get_packet_stream () {
	# Description: ...
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	protocol='http'
	server='localhost:2501'
	endpoint='pcap/all_packets.pcapng'
	# Core actions
	extract_kismet_creds
	credentials="${kismetUsername}:${kismetPassword}"
	wget "${protocol}://${credentials}@${server}/${endpoint}" -O "${HOME}/.pipes/packets"
}

convert_packet_stream_to_ring_buffer_pcapng () {
	# Description: ...
	# Arguments:
	#   ...
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	:
	# Core actions
	tshark -i "${HOME}/.pipes/packets" -b duration:600 -w kismet-
}

shutdown_kismet () {
	# Description: Gracefuly shutdown Kismet processes
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	:
	# Core actions
	killall -q -SIGINT kismet
}

clean_up_artifacts () {
	# Description: Clean up artifacts from actions
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	:
	# Core actions
	remove_temporary_files
}

remove_temporary_files () {
	# Description: Remove temporary files from filesystem
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	:
	# Core actions
	:
}

main "${@}"
