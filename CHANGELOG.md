# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The patch number is calculated with `git rev-list --count HEAD`

## [Unreleased]
### Added
### Changed
### Removed

## [0.1.45] - 2025-06-02
### Added
- `eza` and some aliases
- clock to `mode-line`
- dynamic `tab-bar` in `zellij`
- `s-f` to toggle pane frames in `zellij`
- bindings for `cider-inspector`
### Changed
- `s-t` now accept `SPC u` to open a terminal in the `default-directory` of a file instead of the project root.
- `localleader` to `,`
- `vterm` to show `mode-line`
- `s` is `evil-avy-goto-char-2`
- bindings for `embark`
- `evil-snipe` to use `whole-visible`
- `consult` to show preview almost always
- `recentf` to list only files
- `dired-jump` to work in `magit` too
- `google-cloud-sdk` and `awscli2` to be installed with `devbox`
### Removed
- hack to `cd` in the project dir when opening a new shell. Sometime it was freezing and it was making impossible to `cd` in the `default-directory` of a file.

## [0.1.25] - 2025-04-19
### Added
- `zoxide` volume to persist the list of directories
- `zoxide` emacs package to add `default-directory` to `zoxide` after `find-files`
- `fisher` for fish to be able to install `vfish`
- `vfish` to be able to add folders to `zoxide` from `emacs`
- `OSC7` implemented in `starship` to track the current directory in `vterm` inside `emacs`
### Changed
- `consult-lsp-file-symbols` is mapped to `SP c j` immediately
- `evil-avy-goto-char-timer` works again
### Removed
- `map!` created before KKP that were using `ctrl` instead of `cmd`

## [0.1.18] - 2025-04-18
### Added
- emacs 30.1
- tree-sitter (before it was disabled because it was not working on ARM64)
- neil for clojure
