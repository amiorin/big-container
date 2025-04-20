# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The patch number is calculated with `git rev-list --count HEAD`

## [Unreleased]

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
