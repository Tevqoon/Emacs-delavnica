;;; init.el --- A minimal Emacs config for learning ;;; -*- lexical-binding: t; -*-

;; Initial package management
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(package-refresh-contents)

(dolist (pkg '(use-package company ivy)) ; Essential packages
  (unless (package-installed-p pkg)
    (package-install pkg)))

;; Use a custom-file to avoid cluttering init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Helper functions to facilitate working with different configurations
(defun run-emacs-with-directory (directory &optional arg)
  (interactive "DDirectory: \nP")
  (let ((args (cond ((equal arg '(16)) '("-Q"))
                    (t (list "--init-directory" (expand-file-name directory))))))
    (when (equal arg '(4))
      (setq args (cons "--debug-init" args)))
    (apply #'start-process "emacs" nil "emacs" args)))

(defun run-emacs-with-current-directory (&optional arg)
  "Run Emacs with the current file's directory as the configuration directory.
Calling with single prefix ARG (C-u) enables debugging.
Calling with double prefix ARG (C-u C-u) runs Emacs with -Q."
  (interactive "P")
  (let* ((current-dir (if buffer-file-name
                          (file-name-directory buffer-file-name)
                        default-directory)))
    (run-emacs-with-directory current-dir arg)))
