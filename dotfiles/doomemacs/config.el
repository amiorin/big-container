;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq doom-theme 'doom-one)

(setq display-line-numbers-type 'relative)

(setq org-directory "~/org/")

;; don't prompt before exiting
(setq confirm-kill-emacs nil)
;; don't prompt the first time we start vterm
(setq vterm-always-compile-module t)
;; default path has the wrong permissions
;; (setq server-socket-dir (concat "~/.emacs.d/" (getenv "ZELLIJ_SESSION_NAME") "/"))
;; shortcut to start deer
(evil-global-set-key 'normal "-" 'dired-jump)
;; When done with this frame, type SPC q f`?
(setq server-client-instructions nil)
;; No prompt
(map! :leader
      :desc "Delete frame" "q f" #'delete-frame)

;; No prompt when quitting ediff
;; https://emacs.stackexchange.com/questions/9322/how-can-i-quit-ediff-immediately-without-having-to-type-y
(defun disable-y-or-n-p (orig-fun &rest args)
  (cl-letf (((symbol-function 'y-or-n-p) (lambda (prompt) t)))
    (apply orig-fun args)))
(advice-add 'ediff-quit :around #'disable-y-or-n-p)

(after! keycast
  (define-minor-mode keycast-mode
    "Show current command and its key binding in the mode line."
    :global t
    (if keycast-mode
        (add-hook 'pre-command-hook 'keycast--update t)
      (remove-hook 'pre-command-hook 'keycast--update))))
(add-to-list 'global-mode-string '("" keycast-mode-line))
(require 'keycast)

;; Fix fish problems with emacs
(setq shell-file-name (executable-find "bash"))
(setq-default vterm-shell (executable-find "fish"))
(setq-default explicit-shell-file-name (executable-find "fish"))

;; Cider
(setq cider-save-file-on-load t)
(setq cider-ns-refresh-show-log-buffer t)
(setq cider-ns-save-files-on-refresh t)

;; https://micro.rousette.org.uk/2021/01/03/a-useful-binding.html
(map!
 (:map 'override
  :v "v" #'er/expand-region
  :v "V" #'er/contract-region))

;; no prompt for .dir-locals.el
(setq safe-local-variable-values
      '((cider-preferred-build-tool . clojure-cli)
        (cider-clojure-cli-aliases . ":dev:cider")
        (cider-default-cljs-repl . shadow)
        (cider-shadow-default-options . ":app")
        (cider-ns-refresh-before-fn . "user/stop!")
        (cider-ns-refresh-after-fn . "user/start!")
        (gac-automatically-push-p t)
        (gac-silent-message-p nil)))

;; no prompt for lsp
(setq lsp-auto-guess-root t)

;; discover projects
(setq projectile-project-search-path '(("~/workspaces" . 3) ("~/code/personal" . 2)))
(setq projectile-auto-discover t)
;; create test files if needed
(setq projectile-create-missing-test-files t)

;; loead direnv mode at startup
(use-package! direnv
  :demand t
  :config
  (direnv-mode)
  (add-to-list 'warning-suppress-types '(direnv)))

;; dired
(map! :map dired-mode-map
      :n "h" #'dired-up-directory
      :n "l" #'dired-find-file)

;; smartparens and so on
(use-package! smartparens
  :config
  (require 'smartparens-config))
(add-hook 'prog-mode-hook #'smartparens-strict-mode)
(add-hook 'prog-mode-hook #'evil-cleverparens-mode)
(setq evil-move-beyond-eol t)

;; open terminal on the right
(defun open-term-on-right ()
  (interactive)
  (+evil/window-vsplit-and-follow)
  (+vterm/here nil))

(map! :map global-map
      :ni "C-x C-t" #'open-term-on-right)

;; make easier to find vterm in list buffers
(setq vterm-buffer-name-string "vterm %s")

;; completion with corfu
(after! corfu
  (setq corfu-preview-current nil)
  (setq corfu-quit-at-boundary nil)
  (setq corfu-preselect 'valid)
  (custom-set-faces!
    '(corfu-current :background "#000000")))

;; use avy on s
(setq avy-all-windows t)
(map! :map evil-snipe-local-mode-map :nv "s" #'evil-avy-goto-char-timer)

;; same bindings in vterm
(after! vterm
  (map! :map vterm-mode-map :i "C-w d" #'evil-window-delete)
  (map! :map vterm-mode-map :i "C-w C-o" #'delete-other-windows)
  (map! :map vterm-mode-map :i "C-w v" #'+evil/window-vsplit-and-follow)
  (map! :map vterm-mode-map :i "C-w h" #'evil-window-left)
  (map! :map vterm-mode-map :i "C-w j" #'evil-window-down)
  (map! :map vterm-mode-map :i "C-w k" #'evil-window-up)
  (map! :map vterm-mode-map :i "C-w l" #'evil-window-right))

;; better "SPC c j"
(after! consult-lsp
  (map! :leader
      ;;; <leader> c --- code
        (:prefix-map ("c" . "code")
                     (:when (and (modulep! :tools lsp) (not (modulep! :tools lsp +eglot)))
                       (:when (modulep! :completion vertico)
                         :desc "Jump to symbol in current file workspace" "j"   #'consult-lsp-file-symbols
                         :desc "Jump to symbol in current workspace"      "J"   #'consult-lsp-symbols)))))

;; swap evil-cp-next-opening with evil-cp-previous-opening
(define-key (current-global-map) [remap evil-cp-next-opening] 'evil-cp-previous-opening)
(define-key (current-global-map) [remap evil-cp-previous-opening] 'evil-cp-next-opening)

;; override evil-cleverparens
(defvar evil-cp-additional-movement-keys
  '(("L"   . evil-cp-forward-sexp)
    ("H"   . evil-cp-backward-sexp)
    ("M-H" . evil-cp-beginning-of-defun)
    ("M-h" . (lambda () (interactive) (evil-cp-beginning-of-defun -1)))
    ("M-l" . evil-cp-end-of-defun)
    ("M-L" . (lambda () (interactive) (evil-cp-end-of-defun -1)))
    ("["   . evil-cp-previous-opening)
    ("]"   . evil-cp-next-closing)
    ("{"   . evil-cp-next-opening)
    ("}"   . evil-cp-previous-closing)
    ("("   . evil-cp-backward-up-sexp)
    (")"   . evil-cp-up-sexp)))

;; swap gj with j
(define-key evil-motion-state-map (kbd "j") 'evil-next-visual-line)
(define-key evil-motion-state-map (kbd "k") 'evil-previous-visual-line)
(define-key evil-motion-state-map (kbd "gj") 'evil-next-line)
(define-key evil-motion-state-map (kbd "gk") 'evil-previous-line)

;; python
(setq lsp-pyright-langserver-command "basedpyright")

(defun set-git-name
    (value)
  (setenv "GIT_AUTHOR_NAME" value)
  (setenv "GIT_COMMITTER_NAME" value))

(defun set-git-email
    (value)
  (setenv "GIT_AUTHOR_EMAIL" value)
  (setenv "GIT_COMMITTER_EMAIL" value))

(let ((user (getenv "ZELLIJ_SESSION_NAME")))
  (cond
   ((string-prefix-p "ALBERTO" user)
    (progn (set-git-name "Alberto Miorin")
           (set-git-email "109069886+alberto-of@users.noreply.github.com")
           (setq display-line-numbers-type t)))
   ((string-prefix-p "AMIORIN" user)
    (progn (set-git-name "Alberto Miorin")
           (set-git-email "32617+amiorin@users.noreply.github.com")
           (setq display-line-numbers-type t)))
   ((string-prefix-p "VALERY" user)
    (progn (set-git-name "Valery Lavrentiev")
           (set-git-email "142409766+val-lavrentiev@users.noreply.github.com")
           ;; swap M-x with evil-ex. We M-x more often than :%s
           (map! :nv ":" #'execute-extended-command)
           (map! :leader :nv ":" #'evil-ex)))
   ((string-prefix-p "RAFAEL" user)
    (progn (set-git-name "Rafael Lobo")
           (set-git-email "180167615+rafael-lobo-onefootball@users.noreply.github.com")
           ;; swap M-x with evil-ex. We M-x more often than :%s
           (map! :nv ":" #'execute-extended-command)
           (map! :leader :nv ":" #'evil-ex)))
   ((string-prefix-p "FACUNDO" user)
    (progn (set-git-name "Facundo Diaz")
           (set-git-email "161857284+fdiaz-onefootball@users.noreply.github.com")
           ;; swap M-x with evil-ex. We M-x more often than :%s
           (map! :nv ":" #'execute-extended-command)
           (map! :leader :nv ":" #'evil-ex)))))

(use-package! kkp
  :demand t
  :config (global-kkp-mode +1))

(map! :map 'override "s-s" #'save-buffer)
(map! :map 'override "s-t" #'open-term-on-right)
(map! :map 'override "s-w" #'evil-window-delete)
(map! :map 'override "s-[" #'evil-window-rotate-downwards)
(map! :map 'override "s-]" #'delete-other-windows)
(map! :map 'override "s-n" #'+evil/window-vsplit-and-follow)
(map! :map 'override "s-h" #'evil-window-left)
(map! :map 'override "s-j" #'evil-window-down)
(map! :map 'override "s-k" #'evil-window-up)
(map! :map 'override "s-l" #'evil-window-right)

;; set the agent
(setenv "SSH_AUTH_SOCK" (concat  "/tmp/" (getenv "ZELLIJ_SESSION_NAME") ".agent"))

;; disable some lsp clients
(setq lsp-disabled-clients '(copilot-ls
                             tfls
                             semgrep-ls))

;; use only one buffer for dired
(setq dired-kill-when-opening-new-dired-buffer t)

;; evil-cp
(define-key key-translation-map (kbd "M-S-[") (kbd "M-{"))
(define-key key-translation-map (kbd "M-S-]") (kbd "M-}"))
(define-key key-translation-map (kbd "M-S-9") (kbd "M-("))
(define-key key-translation-map (kbd "M-S-0") (kbd "M-)"))
(define-key key-translation-map (kbd "M-S-j") (kbd "M-J"))
(define-key key-translation-map (kbd "M-S-s") (kbd "M-S"))
(define-key key-translation-map (kbd "M-S-r") (kbd "M-R"))
(define-key key-translation-map (kbd "M-S-l") (kbd "M-L"))
(define-key key-translation-map (kbd "M-S-h") (kbd "M-H"))

(map!
 (:map 'override
  :n "M-5" #'evil-cp-wrap-next-square     ;; [
  :n "M-]" #'evil-cp-wrap-previous-square ;; ]
  ))

;; zoxide and vterm
(use-package! zoxide
  :demand t
  :config
  (setq vterm-clear-scrollback-when-clearing t)
  (setq vterm-eval-cmds '(("find-file" find-file)
                          ("message" message)
                          ("vterm-clear-scrollback" vterm-clear-scrollback)
                          ("dired" dired)
                          ("ediff-files" ediff-files)))
  (add-hook 'find-file-hook (lambda ()
                              (with-current-buffer (current-buffer)
                                (zoxide-add default-directory)))))
