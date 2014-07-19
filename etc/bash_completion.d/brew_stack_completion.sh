# Bash completion script for brew stack
#
# To use, add the following to your .bashrc:
#
#    . $(brew --repository)/Library/Contributions/brew_stash_completion.sh

# Should come AFTER sourcing brew_bash_completion.sh
#
# Alternatively, if you have installed the bash-completion package,
# you can create a symlink to this file in one of the following directories:
#
#    $(brew --prefix)/etc/bash_completion.d
#    $(brew --prefix)/share/bash-completion/completions
#
# Installing to etc/bash_completion.d will cause bash-completion to load
# it automatically at shell startup time. If you choose to install it to
# share/bash-completion/completions, it will be loaded on-demand (i.e. the
# first time you invoke the `brew stack` command in a shell session).

_brew_stack ()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prv=$(__brewcomp_prev)

    case "$cur" in
    --*)
        __brewcomp "
            --help
            --all
            --build-from-source --build-bottle --force-bottle
            --debug
            --devel
            --HEAD
            --ignore-dependencies
            --only-dependencies
            --verbose
            $(brew options --compact "$prv" 2>/dev/null)
            "
        return
        ;;
    esac
    __brew_complete_formulae
}

_brew_pre_stack ()
{
    local i=1 cmd

    # find the subcommand
    while [[ $i -lt $COMP_CWORD ]]; do
        local s="${COMP_WORDS[i]}"
        case "$s" in
        --*)
            cmd="$s"
            break
            ;;
        -*)
            ;;
        *)
            cmd="$s"
            break
            ;;
        esac
        i=$((++i))
    done

    # subcommands have their own completion functions
    case "$cmd" in
    stack)                      _brew_stack ;;
    *)                          _brew;;
    esac
}

complete -o bashdefault -o default -F _brew_pre_stack brew
