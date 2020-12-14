#!/bin/bash

include_paths=()
ESCAPED_HOME=$(printf '%s\n' "$HOME" | sed -e 's/[\/&]/\\&/g')
if [[ (-n "${HOME}") && (-f "${HOME}/.cloudscript") ]]; then
    conf_file="${HOME}/.cloudscript"
elif [[ -f "/etc/cloudscript.conf" ]]; then
    conf_file="/etc/cloudscript.conf"
fi
if [[ -n "${conf_file}" ]]; then
	mapfile -t dirs<<<"$(grep -e '^\s*include_dir\s*=' "${conf_file}" | sed -e 's/.*=\s*\(.*\)$/\1/' -e 's/\s*$//' -e 's/^~/'${ESCAPED_HOME}'/')"
	if [[ (${#dirs[@]} -ne 1) || (-n "${dirs[0]}") ]]; then
		include_paths+=("${dirs[@]}")
	fi
fi
[[ ${#include_paths[@]} -eq 0 ]] && include_paths=('.')

_make_unique() {
	local IFS=$'\n'
	sort -u <<<"$*" | uniq
}

_cloudscriptCompletion() {
    local cloud_dir path file completion_file search results escaped
	if [[ (${COMP_CWORD} -eq 1) && "${COMP_WORDS[0]}" == "%%cloudscript%%" ]]; then
		if [[ ${COMP_WORDS[${COMP_CWORD}]} != ?(.)?(.)/* ]]; then
			for path in "${include_paths[@]}"; do
				search="${path%/}/${COMP_WORDS[${COMP_CWORD}]}"
				escaped=$(printf '%s\n' "${path%/}" | sed -e 's/[\/&]/\\&/g')
				mapfile -t results<<<"$(compgen -o plusdirs -- "${search}" | sed 's/^'"${escaped}\/"'//')"
				if [[ (${#results[@]} -ne 1) || (-n "${results[0]}") ]]; then
					COMPREPLY+=("${results[@]}")
				fi
			done
			mapfile -t COMPREPLY<<<"$(_make_unique "${COMPREPLY[@]}")"
		else
			mapfile -t COMPREPLY<<<"$(compgen -o plusdirs -- "${COMP_WORDS[${COMP_CWORD}]}")"
		fi
		if [[ (${#COMPREPLY[@]} -eq 1) && (-n "${COMPREPLY[0]}") ]]; then
			if [[ ${COMP_WORDS[${COMP_CWORD}]} != ?(.)?(.)/* ]]; then
				local add_noslash=""
				for path in "${include_paths[@]}"; do
					search="${path%/}/${COMPREPLY[0]}/"
					escaped=$(printf '%s\n' "${path%/}" | sed -e 's/[\/&]/\\&/g')
					mapfile -t results<<<"$(compgen -o plusdirs -- "${search}" | sed 's/^'"${escaped}\/"'//')"
					if [[ (${#results[@]} -ne 1) || (-n "${results[0]}") ]]; then
						COMPREPLY+=("${results[@]}")
					fi
					if [[ (-z "${add_noslash}") && (-f "${search}conf") ]]; then
						add_noslash=yes
					fi
				done
				[[ -z "${add_noslash}" ]] && COMPREPLY[0]="${COMPREPLY[0]}/"
				mapfile -t COMPREPLY<<<"$(_make_unique "${COMPREPLY[@]}")"
			else
				mapfile -t values<<<"$(compgen -o plusdirs -- "${COMPREPLY[0]}/")"
				[[ ! -f "${COMPREPLY[0]}/conf" ]] && COMPREPLY[0]="${COMPREPLY[0]}/"
				if [[ (${#values[@]} -ne 1) || (-n "${values[0]}") ]]; then
					COMPREPLY+=("${values[@]}")
				fi
			fi
		fi
		if [[ (${#COMPREPLY[@]} -eq 1) && (-z "${COMPREPLY[0]}") ]]; then
			COMPREPLY=()
		fi
		return
	fi
    cloud_dir="$(dirname "$(realpath "$(/usr/bin/which %%cloudscript%%)")")"

	if [[ ${COMP_CWORD} -eq 2 ]]; then
		IFS=: read -r -a path<<<"$(%%cloudscript%% "${COMP_WORDS[1]}" script_path 2>/dev/null)${cloud_dir}/function"
		mapfile -t COMPREPLY<<<"$(/usr/bin/uniq <(/usr/bin/find "${path[@]}" -name "${COMP_WORDS[2]}*" -maxdepth 1 -executable -type f -printf '%f\n' 2>/dev/null | /usr/bin/sort))"
		if [[ (${#COMPREPLY[@]} -eq 1) && (-z "${COMPREPLY[0]}") ]]; then
			COMPREPLY=()
		fi
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
