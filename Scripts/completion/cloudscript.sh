#!/bin/bash

_cloudscriptCompletion() {
    local cloud_dir path file completion_file
	if [[ (${COMP_CWORD} -eq 1) && "${COMP_WORDS[0]}" == "%%cloudscript%%" ]]; then
		mapfile -t COMPREPLY<<<"$(compgen -o plusdirs -- "${COMP_WORDS[${COMP_CWORD}]}" )"
		if [[ (${#COMPREPLY[@]} -eq 1) && (-n "${COMPREPLY[0]}") ]]; then
			COMPREPLY[0]=${COMPREPLY[0]}/
			mapfile -t values<<<"$(compgen -o plusdirs -- "${COMPREPLY[0]}")"
			if [[ (${#values[@]} -ne 1) || (-n "${values[0]}") ]]; then
				COMPREPLY+=("${values[@]}")
			fi
		fi
		return
	fi
    cloud_dir="$(dirname "$(realpath "$(/usr/bin/which %%cloudscript%%)")")"

	if [[ ${COMP_CWORD} -eq 2 ]]; then
		IFS=: read -r -a path<<<"$(%%cloudscript%% "${COMP_WORDS[1]}" script_path 2>/dev/null)${cloud_dir}/function"
		mapfile -t COMPREPLY<<<"$(/usr/bin/uniq <(/usr/bin/find "${path[@]}" -name "${COMP_WORDS[2]}*" -maxdepth 1 -executable -type f -printf '%f\n' 2>/dev/null | /usr/bin/sort))"
		return
	fi

	file="$(PATH="$(%%cloudscript%% "${COMP_WORDS[1]}" script_path 2>/dev/null))${cloud_dir}/function" /usr/bin/which "${COMP_WORDS[2]}")"
	if [[ -n "${file}" ]]; then
		completion_file="$(dirname "${file}")/completion/${COMP_WORDS[2]}"
		if [[ (-f "${completion_file}") ]]; then
			COMP_CWORD=$(( COMP_CWORD - 2))
			COMP_WORDS=("${COMP_WORDS[@]:2}")
			source "${completion_file}"
		fi
	fi
}
complete -F _cloudscriptCompletion %%cloudscript%%
