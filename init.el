;;; init.el --- A minimal Emacs config for learning ;;; -*- lexical-binding: t; -*-

;;; * Initial package management
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(package-refresh-contents)
(require 'use-package)
(setq use-package-always-ensure t) 	; Install packages automatically

(use-package exec-path-from-shell	; For MacOS users, stabilises shell paths
  :functions exec-path-from-shell-initialize
  :init (exec-path-from-shell-initialize))

;; Use a custom-file to avoid cluttering init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;;; * Aesthetics
(use-package doom-themes
  :init
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'doom-solarized-light) 	; My preferred theme
  ;; (load-theme 'doom-solarized-dark)
  )

(use-package nerd-icons 		; Pretty unicode symbols
  :defer t)

(use-package doom-modeline		; A more aesthetic modeline
  :init (doom-modeline-mode 1)
  (doom-modeline-icon t)		; Add nerd-icon support to the modeline
  :config
  (cond ((eq system-type 'gnu/linux)
	 (setq doom-modeline-height 12))
	(t (setq doom-modeline-height 24))))

(use-package outline-stars		; Sections in comments
  :vc (:url "https://codeberg.org/phmcc/outline-stars")
  :custom
  (outline-stars-level-1-overline)
  (outline-start-default-state 'folded)
  :config
  (outline-stars-mode 1)
  :bind
  (:map prog-mode-map
	("<backtab>" . outline-stars-cycle-buffer))
  )
;;; * Basic configuration

;;; * Essential packages
;;; ** Completion and help
(use-package which-key			; Keybind completion
  :init (which-key-mode)
  :diminish which-key-mode
  :custom (which-key-idle-delay 0.01))

(use-package marginalia 		; Command completion annotations
  :init (marginalia-mode))

(use-package counsel			; Completion framework
  :custom
  (ivy-use-virtual-buffers nil)
  (ivy-count-format "(%d/%d) ")
  (ivy-initial-inputs-alist nil)
  ;; (ivy-dynamic-exhibit-delay-ms 250)
  :bind (("C-s" . swiper)
	 ;; ("s-b" . counsel-switch-buffer)
	 ;; ("M-s s" . swiper-isearch)
	 ;; ("M-s a" . swiper-all)
	 :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done))
  :config
  (ivy-mode 1)
  (counsel-mode)
  ;; NOTE: My preference; I'm not great at remembering order.
  (setq ivy-re-builders-alist '((t . ivy--regex-ignore-order)))
  (setq swiper-use-visual-line-p #'ignore) ; Fix for very long files
  )

(use-package ivy-rich			; Some improvements for ivy
  :after ivy
  :config (ivy-rich-mode 1))

;;; ** Editing
(use-package expreg 			; Cursor expansion
  :custom
  (expreg-restore-point-on-quit t)
  ;; NOTE: I use the super key which might not be bound on not-macos by default
  :bind ("s-f" . expreg-expand)
  )

(use-package multiple-cursors		; Multiple cursors
  :defines mc/keymap
  :defer nil
  :bind (("s-<down>" . mc/mark-next-like-this)
	 ("s-<up>" . mc/mark-previous-like-this)
	 ("s-M-<up>" . mc/unmark-next-like-this)
	 ("s-M-<down>" . mc/unmark-previous-like-this)
	 ("s-d" . mc/mark-all-dwim)
	 ("s-r" . mc/edit-lines)
	 ("s-<mouse-1>" . mc/add-cursor-on-click)
	 :map mc/keymap
	 ("<return>" . nil))		; This allows us to make a newline at each cursor. Exit with C-g
  )

(use-package phi-search)		; In-line search for multiple cursors

(use-package iedit			; Editing multiple things at the same time
  :bind ("C-;" . iedit-mode))

;;; ** Undo
(use-package undo-fu
  :bind (("s-z" . undo-fu-only-undo) 	; NOTE: Again, make sure to bind super
	 ("s-Z" . undo-fu-only-redo)))

(use-package vundo			; Undo-tree
  :custom
  (vundo-glyph-alist vundo-unicode-symbols)
  :bind
  ("C-x u" . vundo))

;;; ** Searching and jumping
(use-package deadgrep			; Ripgrep integration
  :bind ("<f5>" . deadgrep))

(use-package flash			; Jumping all over the screen
  :commands (flash-jump flash-jump-continue
			flash-treesitter)
  :bind ("s-j" . flash-jump)		; NOTE: Make sure super is bound
  :custom
  (flash-multi-window t)
  (flash-rainbow t)
  (flash-rainbow-shade 8)
  (flash-autojump nil) 			; It's hard to keep track of when you get there
  )

;;; ** Lisp programming
(use-package lisp-mode
  :ensure nil  ; built-in package
  :hook ((emacs-lisp-mode . setup-check-parens)
         (common-lisp-mode . setup-check-parens)
         (scheme-mode . setup-check-parens)
         (clojure-mode . setup-check-parens)
	 (racket-mode . setup-check-parens))
  :config
  (defun setup-check-parens ()
    (add-hook 'before-save-hook #'check-parens nil t)))

(use-package paren			; Oklepaji
  :init
  (electric-pair-mode 1)		; Avtomatično banansiraj oklepaje
  (show-paren-mode 1)
  :config
  (defun js/fix-angle-bracket-syntax ()
    "Make < and > punctuation instead of paired delimiters."
    (modify-syntax-entry ?< ".")
    (modify-syntax-entry ?> "."))
  :custom
  (show-paren-delay 0)
  :hook
  (LaTeX-mode . js/fix-angle-bracket-syntax)
  (org-mode . js/fix-angle-bracket-syntax))

(use-package rainbow-delimiters
  :defer t
  :hook prog-mode)

;;; ** Helpful
(use-package helpful
  :bind (("<f1> f" . helpful-callable)
         ("<f1> v" . helpful-variable)
         ("<f1> k" . helpful-key)
         :map help-map
         ("p" . helpful-at-point)
	 :map helpful-mode-map
	 ("q" . quit-window--and-kill))
  :custom
  (helpful-switch-buffer-function #'switch-to-buffer)
  (help-window-select t))		; Always jump to the help buffer

;;; ** Magit
(use-package magit
  :defer t
  :bind
  (("C-x g" . magit-status)
   ("C-x f" . magit-file-dispatch))
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (magit-process-connection-type nil)
  )

(use-package hl-todo
  :config
  (global-hl-todo-mode 1))

(use-package magit-todos
  :after magit
  :config
  (magit-todos-mode 1))
