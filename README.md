# Intro
`doom emacs` development inside a container.

# Install
* Create a script (`~/.local/bin/dev` for example).
* Adapt it to your set-up (replace `amiorin` with your `username`)
* Replace `alberto-of` with your company GitHub name.
* Replace `amiorin` with your personal GitHub name.
* Install `atuin` on Macos.
* Install `OrbStack` on Macos.

``` shell
#!/usr/bin/env bash

gh auth token -u amiorin > /dev/null 2>&1 || (echo Already inside "dev" && exit 1)
[ $? -eq 0 ] || exit 0

mkdir -p ~/.emacs.d/.local/cache
touch ~/.emacs.d/.local/cache/recentf
mkdir -p ~/.m2
mkdir -p ~/.aws
mkdir -p ~/.ssh
chmod 0700 ~/.ssh
mkdir -p ~/.local/share/atuin
mkdir -p ~/.ansible
mkdir -p ~/.local/bin
mkdir -p ~/code/personal
mkdir -p ~/code/of

docker run --rm -it \
           -e GITHUB_TOKEN=`gh auth token -u alberto-of` \
           -e GHP_TOKEN=`gh auth token -u alberto-of` \
           -e GH_TOKEN=`gh auth token -u alberto-of` \
           -e AMIORIN_TOKEN=`gh auth token -u amiorin` \
           --net=host \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v /Users/amiorin/.emacs.d/.local/cache/recentf:/home/vscode/.emacs.d/.local/cache/recentf \
           -v /Users/amiorin/.m2:/home/vscode/.m2 \
           -v /Users/amiorin/.aws:/home/vscode/.aws \
           -v /Users/amiorin/.ssh:/home/vscode/.ssh \
           -v /Users/amiorin/.local/share/atuin:/home/vscode/.local/share/atuin \
           -v /Users/amiorin/.ansible:/home/vscode/.ansible \
           -v /Users/amiorin/.local/bin/dev:/home/vscode/.local/bin/dev \
           -v /Users/amiorin/code/personal:/home/vscode/code/personal \
           -v /Users/amiorin/code/of:/home/vscode/workspaces \
           -v /Users/amiorin:/home/vscode/amiorin \
           ghcr.io/amiorin/big-container:latest \
           fish -c 'zellij attach --create ALBERTO_MACOS && begin pkill emacs || true; end' \
&& kill `ps -o ppid= -p $$`
```

# Multiple GitHub Accounts
To handle multiple GitHub Accounts with this image, you need to clone the repos with
* https://github.com/ for company repos
* https://amiorin@github.com/ for personal repos

# Commit with the correct Author
Create a `.envrc` with the correct Author.

``` shell
export GIT_AUTHOR_NAME="Alberto Miorin"
export GIT_AUTHOR_EMAIL=32617+amiorin@users.noreply.github.com
export GIT_COMMITTER_NAME="Alberto Miorin"
export GIT_COMMITTER_EMAIL=32617+amiorin@users.noreply.github.com
```

