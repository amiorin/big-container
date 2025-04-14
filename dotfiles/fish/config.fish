set -gx SHELL /usr/bin/fish
devbox global shellenv --recompute | source

if status is-interactive
    # agent setup
    if SSH_AUTH_SOCK=/tmp/$ZELLIJ_SESSION_NAME.agent ssh-add -l > /dev/null 2>&1
        set -gx SSH_AUTH_SOCK /tmp/$ZELLIJ_SESSION_NAME.agent
    end

    function register-cmd
        set -l CMD $argv[1]
        set -l TARGET_DIR ~/.config/fish/completions
        set -l TARGET $TARGET_DIR/$CMD.fish
        mkdir -p $TARGET-DIR
        if not test -e $TARGET
        register-python-argcomplete --shell fish $CMD > ~/.config/fish/completions/$CMD.fish
        end
    end

    # ansible
    register-cmd ansible
    register-cmd ansible-playbook

    if test -n "$GITHUB_TOKEN"
        git config --global url."https://$GITHUB_TOKEN:x-oauth-basic@github.com/".insteadOf "https://github.com/"
    end

    if test -n "$AMIORIN_TOKEN"
        git config --global url."https://$AMIORIN_TOKEN:x-oauth-basic@github.com/".insteadOf "https://amiorin@github.com/"
    end

    if test -n "$FACUNDO_TOKEN"
        git config --global url."https://$FACUNDO_TOKEN:x-oauth-basic@github.com/".insteadOf "https://elbarri@github.com/"
    end

    micromamba shell hook --shell fish | source
    starship init fish | source
    zoxide init fish | source
    direnv hook fish | source
    atuin init fish | source

    fish_vi_key_bindings
    # cursor style like vim
    set fish_vi_force_cursor
    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore
    set fish_cursor_replace underscore
    set fish_cursor_external line
    set fish_cursor_visual block

    if test "$INSIDE_EMACS" = "vterm"
        set -gx EDITOR "emacsclient -s $ZELLIJ_SESSION_NAME"
    else
        set -gx EDITOR happy-emacs
    end
    alias emacs=$EDITOR
    alias e=$EDITOR

    set -g fish_greeting
    set -gx COLORTERM truecolor

    # https://the.exa.website/
    alias ls=ls
    alias ll="ls -lh"
    alias l="ls -la"
    alias rt="ls -l --sort newest"
    alias u="cd .."
    alias k=kubectl

    # https://github.com/zellij-org/zellij/issues/3184
    set server_name "$ZELLIJ_SESSION_NAME"
    test -z "$ZELLIJ_SESSION_NAME"; and set server_name "server"
    set emacs_exp '(with-current-buffer (window-buffer (selected-window)) (projectile-project-root))'
    set emacs_dir (emacsclient -a 'echo' --eval "$emacs_exp" -s /tmp/emacs1001/"$server_name" 2> /dev/null)
    if test "$emacs_dir" != "nil"
        if test "$emacs_dir" != "$emacs_exp"
            cd (echo $emacs_dir | jq -r)
        end
    end
end

set -gx POETRY_VIRTUALENVS_IN_PROJECT true
set -gx TZ 'Europe/Berlin'
set -gx LOCALE_ARCHIVE /usr/lib/locale/locale-archive
test -e /var/run/docker.sock; and sudo chmod 777 /var/run/docker.sock
