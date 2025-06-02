<h1 align=center><code>big-container</code></h1>

[![project chat](https://img.shields.io/badge/slack-join_chat-brightgreen.svg)](https://clojurians.slack.com/archives/C08NWQ6NG7N)

`doom emacs` development inside a container. Setting up `doom emacs` requires months. This container is an opinionated version of `doom emacs` tailored for `terminal` development. It is supposed to be used with `Ghostty`.

![screenshot](https://raw.githubusercontent.com/amiorin/big-container/main/screenshot.png)

## Try
``` shell
docker run -it ghcr.io/amiorin/big-container
emacs
```

## Ghostty conf
``` conf
macos-titlebar-style = hidden

mouse-hide-while-typing = true
clipboard-paste-protection = false
copy-on-select = clipboard

font-family = JetBrainsMonoNL Nerd Font Mono
font-size = 16
font-feature = -liga
font-feature = -calt
font-feature = -dlig

keybind = clear

keybind = opt+shift+n=new_window
keybind = opt+shift+w=close_surface

keybind = cmd+v=paste_from_clipboard

keybind = cmd+minus=decrease_font_size:1
keybind = cmd+equal=increase_font_size:1
keybind = cmd+zero=reset_font_size

macos-option-as-alt = true
```

## Features
* ARM64 and AMD64 multi-platform image
* Clojure develpment works out of the box
* Kitty Keyboard Protocol (you can use any combination of cmd, opt, ctrl, and shift)
* Nerd fonts
* Vterm (emacs is the terminal multiplexer, Zellij is used only for tabs)
* Recent files persisted in Macos
* Atuin
* Nix and Devbox to install packages
* Fish shell
* It works in GitHub Action (uid 1001)
* Many tools (check the Dockerfile)
* Zellij
* Direnv
* It supports multiple GitHub accounts

## Install
* Create a script (`~/.local/bin/dev` for example)
* Install `Ghostty` on Macos
* Install `atuin` on Macos
* Install `OrbStack` on Macos
* Replace `amiorin` with your personal GitHub name
* Replace `alberto-of` with your company GitHub name
* Fix the volumes to see your repos inside the container
* Run `dev`

``` shell
#!/usr/bin/env bash

GITHUB_USER=amiorin
GITHUB_USER_ALPHA=alberto-of

gh auth token -u $GITHUB_USER > /dev/null 2>&1 || (echo Already inside "dev" && exit 1)
[ $? -eq 0 ] || exit 0

ZELLIJ_SESSION_NAME=${GITHUB_USER^^}_MACOS
GITHUB_TOKEN=`gh auth token -u $GITHUB_USER`
GITHUB_TOKEN_ALPHA=`gh auth token -u $GITHUB_USER_ALPHA`

mkdir -p ~/.emacs.d/.local/cache
touch ~/.emacs.d/.local/cache/recentf
mkdir -p ~/.m2
mkdir -p ~/.aws
mkdir -p ~/.ssh
chmod 0700 ~/.ssh
mkdir -p ~/.local/share/atuin
mkdir -p ~/.local/share/zoxide
mkdir -p ~/.ansible
mkdir -p ~/.local/bin
mkdir -p ~/code/personal
mkdir -p ~/code/of

docker run --rm -it \
           -e GITHUB_TOKEN=$GITHUB_TOKEN \
           -e GITHUB_TOKEN_ALPHA=$GITHUB_TOKEN_ALPHA \
           -e GH_TOKEN=$GITHUB_TOKEN \
           --net=host \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v ~/.emacs.d/.local/cache/recentf:/home/vscode/.emacs.d/.local/cache/recentf \
           -v ~/.m2:/home/vscode/.m2 \
           -v ~/.aws:/home/vscode/.aws \
           -v ~/.ssh:/home/vscode/.ssh \
           -v ~/.local/share/atuin:/home/vscode/.local/share/atuin \
           -v ~/.local/share/zoxide:/home/vscode/.local/share/zoxide \
           -v ~/.ansible:/home/vscode/.ansible \
           -v ~/.local/bin/dev:/home/vscode/.local/bin/dev \
           -v ~/code/personal:/home/vscode/code/personal \
           -v ~/code/of:/home/vscode/workspaces \
           -v ~:/home/vscode/$USER \
           ghcr.io/amiorin/big-container:latest \
           fish -c "zellij attach --create $ZELLIJ_SESSION_NAME && begin pkill emacs || true; end" \
&& kill `ps -o ppid= -p $$`
```

## Multiple GitHub Accounts
To handle multiple GitHub Accounts with this image, you need to clone the repos with
* https://github.com/ for the main account
* https://alpha@github.com/ for the alpha account
* https://beta@github.com/ for the beta account
* https://gamma@github.com/ for the gamma account

## Commit with the correct Author
If you commit with `magit` you can have a default author defined in `.doom.d/config.el`

``` emacs-lisp
(let ((user (getenv "ZELLIJ_SESSION_NAME")))
  (cond
   ((string-prefix-p "AMIORIN" user)
    (progn (set-git-name "Alberto Miorin")
           (set-git-email "32617+amiorin@users.noreply.github.com")
           (setq display-line-numbers-type t)))
```

Or you can override it with environment variables.
* Create a `.envrc`

``` shell
export GIT_AUTHOR_NAME="Alberto Miorin"
export GIT_AUTHOR_EMAIL=32617+amiorin@users.noreply.github.com
export GIT_COMMITTER_NAME="Alberto Miorin"
export GIT_COMMITTER_EMAIL=32617+amiorin@users.noreply.github.com
```

## Multiplayer development
If you have an machine with ssh in the cloud, you can share it with other
developers. You need to forward your `ssh agent`. Install the Babashka script
`session-from-agent.bb` on the remote machine. An Atuin account needs to be
shared inside the team. The main difference with the first script is that here
it starts a container in the background and it uses `Zellij` to create a session
per developer. Developers can join the session of other developers to pair
program.

``` shell
#!/usr/bin/fish
sudo chmod 666 /var/run/docker.sock

set items ALBERTO FACUNDO VALERY RAFAEL
set config (printf "%s\n" $items | fzf --prompt="Start Zellij » " --height=~50% --layout=reverse --border --exit-0)
if [ -z $config ]
    echo "Nothing selected"
    exit 1
end

set config $config@(hostname)

if not test -z "$SSH_AUTH_SOCK"
   set DEV_NAME (session-from-agent.bb)
   ln -sf $SSH_AUTH_SOCK /tmp/$DEV_NAME@(hostname).agent
end

docker run -d \
           --name devbox \
           -e GH_TOKEN="$GH_TOKEN" \
           -e ATUIN_LOGIN="$ATUIN_LOGIN" \
           --net=host \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v /home/vscode/.emacs.d/.local/cache/recentf:/home/vscode/.emacs.d/.local/cache/recentf \
           -v /home/vscode/.m2:/home/vscode/.m2 \
           -v /home/vscode/.aws:/home/vscode/.aws \
           -v /home/vscode/.ssh:/home/vscode/.ssh \
           -v /home/vscode/.local/share/atuin:/home/vscode/.local/share/atuin \
           -v /home/vscode/.ansible:/home/vscode/.ansible \
           -v /home/vscode/.docker:/home/vscode/.docker \
           -v /home/vscode/workspaces:/home/vscode/workspaces \
           -v /:/home/vscode/stage1-root \
           -v /tmp:/tmp \
           -v /data/ephemeral:/home/vscode/ephemeral \
           ghcr.io/amiorin/big-container \
           tail -f /dev/null \
           > /dev/null 2>&1

docker start devbox > /dev/null 2>&1

exec docker exec -it devbox /home/vscode/.local/share/devbox/global/default/.devbox/nix/profile/default/bin/fish -c "zellij attach --create $config && emacsclient -a 'echo' --eval \"(recentf-save-list)\" -s /tmp/emacs1001/$config > /dev/null 2>&1"
```

## Development
If you want to modify your `config.el`, `config.fish`, or any config file,
better to mount them and rebuild the container when done.

``` shell
# Add this to the docker command
-v ~/code/personal/big-container/main/dotfiles/fish/config.fish:/home/vscode/.config/fish/config.fish \
-v ~/code/personal/big-container/main/dotfiles/doomemacs/config.el:/home/vscode/.doom.d/config.el \
```

## Build
The GitHub Action creates a multi-platform docker image for AMD64 and ARM64.
You can also publish the image from your computer.

``` shell
just publish
```

## Dotfiles
You can `backup` and `install` the dotfiles without rebuilding the image.

``` shell
# Available recipes:
just
# Backup the dotfiles
just backup
# Install the dotfiles
just install
```

## Fix the permission
If you cannot push the image manually in your fork, probably you need to fix the token permissions.

``` shell
gh auth refresh --scopes 'codespace,gist,read:org,repo,workflow,write:packages,delete:packages,read:packages'
```

## License

Copyright © 2025 Alberto Miorin

`big-container` is released under the [MIT License](https://opensource.org/licenses/MIT).
