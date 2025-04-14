# list of all recipes
help:
    @just -f {{ justfile() }} --list --unsorted

# backup dotfiles
backup:
    cp ~/.config/fish/config.fish dotfiles/fish/config.fish
    cp ~/.config/direnv/direnv.toml dotfiles/direnv/direnv.toml
    cp ~/.config/zellij/config.kdl dotfiles/zellij/config.kdl
    cp ~/.config/zellij/layouts/minimal.kdl dotfiles/zellij/layouts/minimal.kdl
    cp ~/.doom.d/config.el dotfiles/doomemacs/config.el
    cp ~/.doom.d/init.el dotfiles/doomemacs/init.el
    cp ~/.doom.d/packages.el dotfiles/doomemacs/packages.el
    rsync -a --delete ~/.doom.d/modules/lang/protobuf/ dotfiles/doomemacs/modules/lang/protobuf
    cp ~/.config/atuin/config.toml dotfiles/atuin/config.toml
    cp ~/.config/starship.toml dotfiles/starship/starship.toml
    cp ~/.local/bin/happy-emacs dotfiles/bin/happy-emacs

# install dotfiles
install:
    rsync -a dotfiles/bin/ ~/.local/bin
    cp dotfiles/starship/starship.toml ~/.config/starship.toml
    rsync -a dotfiles/atuin/ ~/.config/atuin
    cp dotfiles/git/.gitconfig ~/.gitconfig
    rsync -a dotfiles/fish/ ~/.config/fish
    rsync -a dotfiles/direnv/ ~/.config/direnv
    rsync -a dotfiles/zellij/ ~/.config/zellij
    rsync -a dotfiles/doomemacs/ ~/.doom.d
