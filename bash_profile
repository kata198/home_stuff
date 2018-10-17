#
# ~/.bash_profile
#

if [ "${FROM_BASHRC}" != "1" ];
then
    [[ -f ~/.bashrc ]] && . ~/.bashrc
fi


_get_variable_value() {
    VAR_NAME="${1}"

#    VAR_VALUE="$(export | grep "${VAR_NAME}" | sed 's/^.*=//g' | sed 's/"//g')"

    VAR_VALUE="$(/usr/bin/python -c "import os; import sys; sys.stdout.write(os.environ.get('${VAR_NAME}', ''))")"

    if [ ! -z "${VAR_VALUE}" ];
    then
        echo "${VAR_VALUE}"
        return 0;
    else
        return 1;
    fi
}

path_rem() {
    VAR_NAME="$1"
    if [ "${VAR_NAME}" = "-q" ];
    then
        _IS_QUIET="true"
        shift
        VAR_NAME="$1"
    else
        _IS_QUIET="false"
    fi

    TO_REM="$2"

    if [ $# -ne 2 ];
    then
        echoerr -e "Wrong number of arguments.\nUsage: path_rem [var name] [var value portion]\n"
        return 2;
    fi
    if [ -z "${TO_REM}" ];
    then
        echoerr "var value cannot be empty."
        return 2;
    fi
    if [ -z "${VAR_NAME}" ];
    then
        echoerr "var name cannot be empty."
        return 2;
    fi
        

    OLD_VAR_VALUE="$(_get_variable_value "${VAR_NAME}")"

    TO_REM="$(echo "${TO_REM}" | sed 's|[/][/]*$||g')"

    [[ -z "${TO_REM}" ]] && TO_REM="/"

    OLD_VAR_SPLIT="$(echo "${OLD_VAR_VALUE}" | tr ':' '\n')"
    OLD_VAR_SPLIT="$(echo "${OLD_VAR_SPLIT}")" # Ensure newline
    
    NEW_VALUE="$(/usr/bin/python -c "import sys; sys.stdout.write ( ':'.join([x for x in '''${OLD_VAR_VALUE}'''.split(':') if x != '"${TO_REM}"'])) ")"

    export "${VAR_NAME}"'='"${NEW_VALUE}"

    [[ "${_IS_QUIET}" = "false" ]] &&  echo "$(_get_variable_value "${VAR_NAME}")"
    return 0
}
    

path_add_uniq() {
    VAR_NAME="$1"
    if [ "${VAR_NAME}" = "-q" ];
    then
        _IS_QUIET="true"
        shift
        VAR_NAME="$1"
    else
        _IS_QUIET="false"
    fi

    TO_ADD="$2"

    if [ $# -ne 2 ];
    then
        echoerr -e "Wrong number of arguments.\nUsage: path_add_uniq [var name] [var value]\n"
        return 2;
    fi
    if [ -z "${TO_ADD}" ];
    then
        echoerr "var value cannot be empty."
        return 2;
    fi
    if [ -z "${VAR_NAME}" ];
    then
        echoerr "var name cannot be empty."
        return 2;
    fi
        

    OLD_VAR_VALUE="$(_get_variable_value "${VAR_NAME}")"

    TO_ADD="$(echo "${TO_ADD}" | sed 's|[/][/]*$||g')"

    [[ -z "${TO_ADD}" ]] && TO_ADD="/"

    OLD_VAR_SPLIT="$(echo "${OLD_VAR_VALUE}" | tr ':' '\n')"
    OLD_VAR_SPLIT="$(echo "${OLD_VAR_SPLIT}")" # Ensure newline
    


    if ! ( echo "${OLD_VAR_SPLIT}" | grep -qE "^${TO_ADD}[/]*$" );
    then
        RET=0
        if [ -z "${OLD_VAR_VALUE}" ];
        then
            NEW_VALUE="${TO_ADD}"
        else
            NEW_VALUE="${TO_ADD}:${OLD_VAR_VALUE}"
        fi
        export "${VAR_NAME}"'='"${NEW_VALUE}"
    else
        RET=1
    fi
    [[ "${_IS_QUIET}" = "false" ]] &&  echo "$(_get_variable_value "${VAR_NAME}")"
    return ${RET}
}
 

export PATH="$(/usr/bin/python -c "import sys; import re; sys.stdout.write(re.sub('[\\r\\n\\0]', ':', '''${PATH}'''))")"

path_rem -q  PATH "/usr/local/bin"
path_add_uniq -q PATH "/usr/bin"
path_add_uniq -q PATH "$HOME/bin"

alias cgrep="grep --color=auto"
alias defaultenv="deactivate >/dev/null 2>&1; source ~/envs/default/bin/activate"
alias defaultenv2="deactivate >/dev/null 2>&1; source ~/envs/default2/bin/activate"

alias rebashrc="source ~/.bash_profile"

shopt -s globstar

echoerr() {
    echo "$@" >&2
}

printferr() {
    printf "$@" >&2
}

getmod() {
    git status | grep 'modified:' | sed 's/.*modified:[ \t]*//g' | tr '\n' ' '
}

gitc() {
    _GITC_BRANCH="${1}"

    git checkout "${_GITC_BRANCH}"
    if [[ $? -ne 0 ]];
    then
        printferr "\nERR: Failed to checkout '%s'\n\n" "${_GITPU_BRANCH}"
        return 190;
    fi

    return 0;
}

gitpu() {

    if [[ $# -eq 0 ]];
    then
        git push
        RET=$?
    else
        git push "$@"
        RET=$?
    fi

    if [[ "${RET}" -ne 0 ]];
    then
        printferr "\nERR: Failed to push changes. See above error.\n\n"
        return 192;
    fi

    return 0;
}


gcp() {
    _GCP_BRANCH="${1}"

    gitc "${_GCP_BRANCH}" || return $?

    git pull --rebase
    if [ $? -ne 0 ];
    then
        printferr "\nERR: Failed to rebase upstream changes into '%s'\n\n" "${_GCP_BRANCH}"
        return 191;
    fi
}

export VISUAL="vim"
export PYTHONSTARTUP="$HOME/.pystartup"


path_add_uniq -q 'PYTHONPATH' "$HOME/.python/libs"

fixterm() {
    OLD_TERM="${TERM}"
    export TERM="xterm"
    export TERM="${OLD_TERM}"
}

  function tmp() {
	if [ -z "$_TMP_OLD_DIR" ];
	then
		export _TMP_OLD_DIR=$(pwd)
	fi
	mkdir -p "${HOME}/tmp";
	cd "${HOME}/tmp";
    if [ ! -z "$1" ];
    then
        cd __${1}_*
    fi
  }

  function untmp() {
	if [ "$1" = "-k" ];
	then
		_DEL_OLD_DIR=
	else
		_DEL_OLD_DIR="$(pwd)"
	fi
	if [ -z "$_TMP_OLD_DIR" ];
	then
		echo "Not in temp mode." >&2
		return 1
	fi
	cd $_TMP_OLD_DIR
	export _TMP_OLD_DIR=
	unset _TMP_OLD_DIR
	if [ ! -z "$_DEL_OLD_DIR" ];
	then
		rm -Rf "$_DEL_OLD_DIR";
	fi
  }
  function mktmp() {
	untmp >/dev/null 2>&1 || true
	tmp;
	NAME=$(mktemp -d __$1_XXXXXXXX)
	cd "$NAME"
	pwd;
  }


  function stripslash() {
    DIRNAME=$(dirname "$1")
    BASENAME=$(basename "$1")
    [ "$DIRNAME" = "/" ] && DIRNAME=
    echo "$DIRNAME/$BASENAME"
  }


function findgcdatimes() {
    findgcda "$@" | get_sorted_mtime
}
