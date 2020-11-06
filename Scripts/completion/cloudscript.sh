#!/bin/bash

_cloudcompletion() {
    local script="$(realpath "$(which cloudscript)")"
    local cloud_dir="$(realpath "$(dirname "${script}")/../")"
    local dirs=("${cloud_dir}/Containers" "${cloud_dir}/Packages")
    local words=()
    local current=0
    
    # Bash completion understand : as another argument
    # need to join NAME:TAG
    local skip_third=false
    for index in ${!COMP_WORDS[*]}; do
	if [[ ${index} -eq 2 && "${COMP_WORDS[2]}" == ":"* ]]; then
	    words[$((${current}-1))]="${words[$(($current-1))]}${COMP_WORDS[2]}${COMP_WORDS[3]}"
	    skip_third=true
	elif [[ ${index} -ne 3 || ! ${skip_third} ]]; then
	    words[current]="${COMP_WORDS[${index}]}"
	    ((current++))
	fi
    done

    case ${#words[@]} in
	2)
	    # tag completion
	    local search=${words[1]}
	    COMPREPLY=()
	    local name=${search%:*}
	    if [[ "${name}" == "${search}" ]]; then
		for index in ${!dirs[*]}; do
		    for dir in $(cd "${dirs[${index}]}" >/dev/null 2>&1 && ls -dD "${name}"*/ 2>/dev/null); do
                        COMPREPLY+=("${dir%/}")
                        last="${dirs[${index}]}/${dir}"
			# for tag in $(cd "${dirs[${index}]}/${dir}" && ls -dD */ 2>/dev/null); do
                        #     # conf file is required
                        #     if [[ -f "${dirs[${index}]}/${dir}${tag}conf" ]]; then
			#         COMPREPLY+=("${dir%/}:${tag%/}")
                        #     fi
			# done
		    done
		done
                # if there is only one target, list versions
                if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
                    dir="${COMPREPLY[@]}"
                    COMPREPLY=()
		    for tag in $(cd "${last}" && ls -dD */ 2>/dev/null); do
                        # conf file is required
                        if [[ -f "${last}${tag}conf" ]]; then
			    COMPREPLY+=("${dir%/}:${tag%/}")
                        fi
		    done
                    # there are no versions.
                    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
                        COMPREPLY=("${dir}:")
                    fi
                fi
	    else
		local tag=${search##*:}
		for index in ${!dirs[*]}; do
		    for _tag in $(cd "${dirs[${index}]}/${name}" >/dev/null 2>&1 && ls -dD "${tag}"*/ 2>/dev/null); do
                        # conf file is required
                        if [[ -f "${dirs[${index}]}/${name}/${_tag}conf" ]]; then
			    COMPREPLY+=("${_tag%/}")
                        fi
		    done
		done
	    fi
	    ;;
	3)
	    #command completion
	    local tag=${words[1]}
	    local path="$(cloudscript ${tag} script_path 2>/dev/null)${cloud_dir}/Scripts/function"
	    oldifs=${IFS}
	    IFS=:
	    local data=($(/usr/bin/uniq <(/usr/bin/find $path -name "${words[2]}*" -maxdepth 1 -executable -type f -printf '%f\n' 2>/dev/null | /usr/bin/sort)))
	    IFS=${oldifs}
	    COMPREPLY=(${data[*]})
	    ;;
    esac
}


complete -F _cloudcompletion cloudscript
