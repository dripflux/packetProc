#!/usr/bin/env bash

# NAME
#	nmapProc.sh  Common Kismet use cases
#
# SYNOPSIS
#	nmapProc.sh help
#	nmapProc.sh info
#
#	nmapProc.sh ...
#
# DESCRIPTION
#	...
#
#	Subcommands:
#
#	help  (base subcommand) Display help message, supports single term filtering.
#
#	ls, list  (base subcommand) Display non-base subcommands.
#
#   info  (base subcommand) Display config and version information.
#
# EXIT STATUS
#	0  : (normal) On success
#	1+ : ERROR
#	2  : ERROR: Invalid usage
#
# DEPENDENCIES
#	basename(1) : POSIX basename
#	echo(0|1)   : Builtin or POSIX echo
#	egrep(1)    : POSIX egrep
#	grep(1)     : POSIX grep
#	less(1)     : GNU (common UNIX) less
#	tr(1)       : POSIX tr

# Save script name
SELF="${0}"

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
	setUpEnv
	# Core actions
	case ${subcommand} in
		help )       # (base subcommand) Display this help message, supports single term filtering
			searchTerm="${1}"
			shift
			usage "${searchTerm}"
			;;
		ls | list )  # (base subcommand) List non-base subcommands
			listNonBaseSubcommands
			;;
		info )       # (base subcommand) Display configuration and version information
			displayInfo
			;;
		* )
			# Default: Blank or unknown subcommand, report error if unknown subcommand
			# Note: Lack of comment on same line as case, default action will not be displayed by usage or ls subcommand
			usage
			if [[ -n "${subcommand}" ]] ; then
				errorExit "ERROR: Unknown subcommand: ${subcommand}" 2
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

errorExit () {
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
	cleanUpArtifacts
	exit "${errorStatus}"
}

warningReport () {
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

listNonBaseSubcommands () {
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

setUpEnv () {
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

displayInfo () {
	# Description: Display configuration and version information
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	:
	# Core actions
	nmap --version
}

cleanUpArtifacts () {
	# Description: Clean up artifacts from actions
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	:
	# Core actions
	removeTempFiles
}

removeTempFiles () {
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
