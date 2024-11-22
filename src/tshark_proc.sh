#!/usr/bin/env bash


## NAME
##	tshark_proc.sh  Process PCAPs using TShark.
##
## SYNOPSIS
##	tshark_proc.sh help
##
##	??? ...
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
##	version  (base subcommand) Display version information.
##
## EXPERT
##	The following environment variables can be set to affect execution:
##
##	- reportError       : Defaults to "echo" if not set, command to use when reporting error messages
##	- reportWarning     : Defaults to "echo" if not set, command to use when reporting warning messages
##	- reportCaution     : Defaults to ":" if not set, command to use when reporting caution messages
##	- reportInformation : Defaults to ":" if not set, command to use when reporting information and completion messages
##	- reportTelemetry   : Defaults to ":" if not set, command to use when reporting telemetry messages
##	- reportDebug       : Defaults to ":" if not set, command to use when reporting debug messages
##
## EXIT STATUS
##	0  : (normal) On success
##	1+ : ERROR
##	2  : ERROR: Invalid usage
##
## DEPENDENCIES
##	echo(0|1)   : Built-in or POSIX echo
##	egrep(1)    : POSIX egrep
##	grep(1)     : POSIX grep
##	less(1)     : GNU (common UNIX) less
##	sort(1)     : POSIX sort.
##	tr(1)       : POSIX tr


# Save script name
SELF="${0}"
SEMVER_STRING="0.1.0"  # See URL: https://semver.org/


main () {
	# Description: Main control flow
	# Arguments:
	#   ${@} : Argv.
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	set_up_environment
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	subcommand="${1}"
	shift
	# Core actions
	case ${subcommand} in
		help )       # (base subcommand) Display this help message, supports single term filtering.
			searchTerm="${1}"
			shift
			usage "${searchTerm}"
			;;
		ls | list )  # (base subcommand) List non-base subcommands.
			list_non_base_subcommands
			;;
		manual )     # (base subcommand) Display full manual.
			manual
			;;
		version )    # (base subcommand) Display version information.
			version_info
			;;
		* )
			# Default: Blank or unknown subcommand, report error if unknown subcommand
			# Note: Lack of comment on same line as case, default action will not be displayed by usage or ls subcommand
			if [[ -z "${subcommand}" ]] ; then  # Blank subcommand
				usage
			else
				exit_error "ERROR: Unknown subcommand: ${subcommand}" 2
			fi
			;;
	esac
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


usage () {
	# Description: Generate and display usage
	# References:
	#   - Albing, C., JP Vossen. bash Idioms. O'Reilly. 2022.
	# Arguments:
	#   ${1} : (Optional) Search term
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	searchTerm="${1}"
	shift
	# Core actions
	(
		echo "${SELF##*/}" 'Usage:'
		egrep '[[:space:]]\)[[:space:]]+#[[:space:]]' "${SELF}" | tr -s '\t' | sort
	) | grep -i "${searchTerm:-.}" | less
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


manual () {
	# Description: Display full manual
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	grep -B 1 '[#][#][[:space:]]' "${SELF}" | less
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


version_info () {
	# Description: Output version information.
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	echo "${SELF##*/}" "${SEMVER_STRING}"
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


set_up_environment () {
	# Description: Set up environment.
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	# Core actions
	: ${reportError:=echo}
	: ${reportWarning:=echo}
	: ${reportCaution:=:}
	: ${reportInformation:=:}
	: ${reportTelemetry:=:}
	: ${reportDebug:=:}
	: ${TMPDIR:=/tmp}
}


exit_error () {
	# Description: Output ${1} (error message) to stderr and exit with ${2} (error status).
	# Arguments:
	#   ${1} : Error message to write.
	#   ${2} : (Optional) Error status to exit with.
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	errorStatus=1
	errorMessage="${1}"
	shift
	# Core actions
	${reportError} '[!] ERROR:' "${errorMessage}" >&2
	if [[ -n "${1}" ]] ; then
		errorStatus="${1}"
	fi
	clean_up_artifacts
	exit "${errorStatus}"
}


report_warning () {
	# Description: Output ${1} (warning message) to stderr as warning.
	# Arguments:
	#   ${1} : Warning message to write.
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	warningMessage="${1}"
	shift
	# Core actions
	echo '[!] WARNING:' "${warningMessage}" >&2
}


report_caution () {
	# Description: Output ${1} (caution message) to stderr as caution.
	# Arguments:
	#   ${1} : Caution message to write.
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	cautionMessage="${1}"
	shift
	# Core actions
	"${reportCaution}" '[^] CAUTION:' "${cautionMessage}" >&2
}


report_information () {
	# Description: Output ${1} (information message) to stderr as information.
	# Arguments:
	#   ${1} : Information message to write.
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	informationMessage="${1}"
	shift
	# Core actions
	"${reportInformation}" '[-] INFO:' "${informationMessage}" >&2
}


report_complete () {
	# Description: Output ${1} (completion message) to stderr as information.
	# Arguments:
	#   ${1} : Completion message to write.
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	completionMessage="${1}"
	shift
	# Core actions
	"${reportInformation}" '[+] INFO:' "${completionMessage}" >&2
}


report_telemetry () {
	# Description: Output ${1} (telemetry message) to stderr as telemetry.
	# Arguments:
	#   ${1} : Telemetry message to write.
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	telemetryMessage="${1}"
	shift
	# Core actions
	"${reportTelemetry}" '[.] TELEMETRY:' "${SELF##*/}::${telemetryMessage}" >&2
}


report_debug () {
	# Description: Output ${1} (debug message) to stderr as debug.
	# Arguments:
	#   ${1} : Debug message to write.
	# Return:
	#   0  : (normal).
	#   1+ : ERROR.

	# Set up working set
	debugMessage="${1}"
	shift
	# Core actions
	"${reportDebug}" '[.] DEBUG:' "${debugMessage}" >&2
}


list_non_base_subcommands () {
	# Description: Generate and display list of non-base subcommands
	# References:
	#   - Albing, C., JP Vossen. bash Idioms. O'Reilly. 2022.
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	(
		echo "${SELF##*/}" 'Subcommands:'
		egrep '[[:space:]]\)[[:space:]]+#[[:space:]]' "${SELF}" | grep -v 'base[[:space:]]subcommand' | tr -s '\t' | sort
	) | less
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


clean_up_artifacts () {
	# Description: Clean up artifacts from actions
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	remove_temporary_files
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


remove_temporary_files () {
	# Description: Remove temporary files from filesystem
	# Arguments:
	#   (none)
	# Return:
	#   0  : (normal)
	#   1+ : ERROR

	# Set up working set
	report_telemetry "${FUNCNAME[0]}()"
	report_debug "${SELF##*/}::${FUNCNAME[0]}(${*})"
	# Core actions
	:
	report_debug "${SELF##*/}::${FUNCNAME[1]}() <-- ${FUNCNAME[0]}()"
}


# Developer Note: This script supports running as a script like normal and sourcing as a library.
# 1. Change the below variable name to a unique ID for this script.
#    - Recommendation: Change "_THIS_" to the name of this scirpt
#    - E.g. ${source__THIS__as_library} --> ${source_bash_automator_as_library}
# 2. Assign a value to the uniquely named variable in the script you want to source this library from.
#    - E.g. source_bash_automator_as_library=y
# 3. Source this script in the other script referencing this script as a library
#    - E.g. source bash_automator.sh
# NOTE: bash does not have the concept of namespaces, name collisions will overwrite previous assignments when sourced.
if [[ -z ${source__THIS__as_library} ]] ; then
	main "${@}"
fi
