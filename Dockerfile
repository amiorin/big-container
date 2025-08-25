FROM mcr.microsoft.com/devcontainers/base:ubuntu

# postgres
RUN mkdir /run/postgresql \
    && chmod 1777 /run/postgresql

# Step 1: Installing dependencies
RUN apt-get update
RUN apt-get -y install acl bash binutils git xz-utils wget sudo iputils-ping file

# Step 1.1: Change uid and gid to be compatible with Github Actions
RUN usermod -u 1001 vscode \
    && groupmod -g 1001 vscode \
    && chown -R vscode:vscode /home/vscode \
    && chsh -s /usr/bin/fish vscode

# Step 1.5: Setting up devbox user
ENV DEVBOX_USER=vscode
USER $DEVBOX_USER
WORKDIR /home/${DEVBOX_USER}

# Step 2: Installing Nix
RUN wget --output-document=/dev/stdout https://nixos.org/nix/install | sh -s -- --no-daemon
RUN . ~/.nix-profile/etc/profile.d/nix.sh

ENV PATH="/home/${DEVBOX_USER}/.nix-profile/bin:$PATH"

# Optional arg to install custom devbox version
ARG DEVBOX_USE_VERSION
# Step 3: Installing devbox
ENV DEVBOX_USE_VERSION=$DEVBOX_USE_VERSION
RUN wget --quiet --output-document=/dev/stdout https://get.jetify.com/devbox | bash -s -- -f
RUN chown -R "${DEVBOX_USER}:${DEVBOX_USER}" /usr/local/bin/devbox
ENV PATH="/home/${DEVBOX_USER}/.local/share/devbox/global/default/.devbox/nix/profile/default/bin:$PATH"

# asdf
RUN curl -L https://github.com/asdf-vm/asdf/releases/download/v0.18.0/asdf-v0.18.0-linux-$(dpkg --print-architecture).tar.gz -o asdf.tar.gz \
    && mkdir -p ~/.config/fish/completions \
    && tar zxvf asdf.tar.gz \
    && sudo mv asdf /usr/local/bin \
    && rm asdf.tar.gz \
    && asdf plugin add java https://github.com/halcyon/asdf-java.git \
    && asdf install java temurin-21.0.7+6.0.LTS \
    && asdf set --home java temurin-21.0.7+6.0.LTS \
    && asdf plugin add duckdb https://github.com/amiorin/asdf-duckdb.git \
    && asdf install duckdb latest \
    && asdf set --home duckdb latest \
    && asdf plugin add hugo https://github.com/Edditoria/asdf-hugo.git \
    && asdf install hugo latest:extended \
    && asdf set --home hugo latest:extended \
    && asdf plugin add golang https://github.com/asdf-community/asdf-golang.git \
    && asdf install golang latest \
    && asdf set --home golang latest \
    && asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git \
    && asdf install nodejs latest \
    && asdf set --home nodejs latest \
    asdf completion fish > ~/.config/fish/completions/asdf.fish

RUN git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d \
    && cd ~/.emacs.d \
    && git fetch origin 68010af0906171e3c989fc19bcb3ba81f7305022:refs/remotes/origin/pin-last-working-commit \
    && git checkout 68010af0906171e3c989fc19bcb3ba81f7305022
ENV PATH="/home/${DEVBOX_USER}/.emacs.d/bin:$PATH"

# Step 4: Install packages
RUN devbox global add lorri
RUN devbox global add dart-sass
RUN devbox global add opentelemetry-collector
RUN devbox global add socat
RUN devbox global add google-cloud-sdk
RUN devbox global add awscli2
RUN devbox global add fish
RUN devbox global add ripgrep
RUN devbox global add zellij
RUN devbox global add starship
RUN devbox global add direnv
RUN devbox global add gh
RUN devbox global add fd
RUN devbox global add fzf
RUN devbox global add atuin
RUN devbox global add cmake
RUN devbox global add just
RUN devbox global add libtool
RUN devbox global add pipx
RUN devbox global add saml2aws
RUN devbox global add docker
RUN devbox global add tini
RUN devbox global add babelfish
RUN devbox global add clojure-lsp
RUN devbox global add terraform-ls
RUN devbox global add minio
RUN devbox global add kubectl
RUN devbox global add kubectx
RUN devbox global add k9s
RUN devbox global add opentofu
RUN devbox global add hcl2json
RUN devbox global add gum
RUN devbox global add minikube
RUN devbox global add kubernetes-helm
RUN devbox global add cljfmt
RUN devbox global add dig
RUN devbox global add protoscope
RUN devbox global add protobuf
RUN devbox global add bun
RUN devbox global add micromamba
RUN devbox global add go
RUN devbox global add zig
RUN devbox global add babashka
RUN devbox global add jet
RUN devbox global add uv
RUN devbox global add ruff
RUN devbox global add overmind
RUN devbox global add leiningen
RUN devbox global add s5cmd
RUN devbox global add clojure
RUN devbox global add zoxide
RUN devbox global add eza
RUN devbox global add pixi
RUN devbox global add yj
RUN devbox global add mysql80@8.0.36 --disable-plugin
RUN devbox global add postgresql@14.9 --disable-plugin
RUN devbox global add nginx --disable-plugin
RUN devbox global add emacs

RUN sudo ln -sf /home/${DEVBOX_USER}/.local/share/devbox/global/default/.devbox/nix/profile/default/bin/fish /usr/bin/fish \
    && echo /usr/bin/fish | sudo tee -a /etc/shells \
    && echo /home/${DEVBOX_USER}/.local/share/devbox/global/default/.devbox/nix/profile/default/bin/fish | sudo tee -a /etc/shells \
    && sudo chsh -s /usr/bin/fish ${DEVBOX_USER}
RUN devbox global run -- fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher && fisher install pymander/vfish'


RUN mkdir ~/.npm-global \
    && devbox global run -- npm config set prefix '~/.npm-global' \
    && devbox global run -- npm -g install @devcontainers/cli \
                                           parcel \
                                           prettier
ENV PATH="/home/${DEVBOX_USER}/.npm-global/bin:$PATH"

RUN mkdir ~/.docker

RUN devbox global run -- micromamba create --yes --name py3.10 --channel conda-forge python=3.10
RUN devbox global run -- micromamba create --yes --name py3.11 --channel conda-forge python=3.11
RUN devbox global run -- pipx install --python /home/${DEVBOX_USER}/micromamba/envs/py3.10/bin/python3.10 poetry meltano==2.20 basedpyright ruff ansible-core
RUN devbox global run -- pipx inject --include-apps --include-deps ansible-core argcomplete boto3
ENV PATH="/home/${DEVBOX_USER}/.local/bin:$PATH"

RUN curl -L https://github.com/kovidgoyal/kitty/releases/download/v0.39.1/kitten-linux-$(dpkg --print-architecture) -o /home/${DEVBOX_USER}/.local/bin/kitten \
    && chmod 0755 /home/${DEVBOX_USER}/.local/bin/kitten

RUN devbox global run -- go install golang.org/x/tools/gopls@latest
RUN devbox global run -- go install github.com/x-motemen/gore/cmd/gore@latest
RUN devbox global run -- go install github.com/stamblerre/gocode@latest
RUN devbox global run -- go install golang.org/x/tools/cmd/godoc@latest
RUN devbox global run -- go install golang.org/x/tools/cmd/goimports@latest
RUN devbox global run -- go install golang.org/x/tools/cmd/gorename@latest
RUN devbox global run -- go install golang.org/x/tools/cmd/guru@latest
RUN devbox global run -- go install github.com/cweill/gotests/...@latest
RUN devbox global run -- go install github.com/fatih/gomodifytags@latest
ENV PATH="/home/${DEVBOX_USER}/go/bin:$PATH"

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/home/${DEVBOX_USER}/.cargo/bin:$PATH"

RUN devbox global run -- clojure -Ttools install-latest :lib com.github.liquidz/antq :as antq
RUN devbox global run -- clojure -Ttools install com.github.seancorfield/clj-new '{:git/tag "v1.2.404"}' :as clj-new
RUN devbox global run -- clojure -Ttools install-latest :lib io.github.seancorfield/deps-new :as new
RUN mkdir -p ~/.local/bin && curl -o- -L https://raw.githubusercontent.com/babashka/bbin/v0.2.4/bbin > ~/.local/bin/bbin && chmod +x ~/.local/bin/bbin
RUN bbin install io.github.babashka/neil
RUN neil --version

COPY justfile /tmp/dotfiles/justfile
COPY dotfiles /tmp/dotfiles/dotfiles
RUN cat /tmp/dotfiles/xterm-ghostty | tic -x -
RUN devbox global run -- bash -c "cd /tmp/dotfiles && just install"
RUN devbox global run -- bash -c "mkdir -p ~/.doom.d/snippets"
RUN devbox global run -- ~/.emacs.d/bin/doom sync
RUN devbox global run -- emacs --fg-daemon --eval '(setq vterm-always-compile-module t)' --eval '(vterm-module-compile)' --eval '(kill-emacs)'
RUN devbox global run -- npm -g --prefix /home/${DEVBOX_USER}/.emacs.d/.local/etc/lsp/npm/dockerfile-language-server-nodejs install dockerfile-language-server-nodejs
RUN devbox global run -- npm -g --prefix /home/${DEVBOX_USER}/.emacs.d/.local/etc/lsp/npm/basedpyright install basedpyright
RUN devbox global run -- npm -g --prefix /home/${DEVBOX_USER}/.emacs.d/.local/etc/lsp/npm/yaml-language-server install yaml-language-server

ENTRYPOINT ["tini", "--"]

CMD ["fish"]
