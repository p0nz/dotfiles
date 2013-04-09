;; Store as ~/.emacs

;; Always display error backtraces
(setq debug-on-error t)

(require 'package)
(setq package-archives
      (append '(("marmalade" . "http://marmalade-repo.org/packages/")
                ("melpa" . "http://melpa.milkbox.net/packages/"))
              package-archives))
(package-initialize)

;; Disable start screen
(setq inhibit-startup-screen t)

;; Disable backup files
(setq make-backup-files nil
      auto-save-default nil
      backup-inhibited t)

;; Empty Markdown scratch
(setq initial-scratch-message nil
      initial-major-mode 'markdown-mode)

;; M-g navigates to specified line
(global-set-key (kbd "M-g") 'goto-line)

;; M-; toggles commenting for marked region or current line.
(autoload 'evilnc-comment-or-uncomment-lines "evil-nerd-commenter" "" t)
(global-set-key "\M-;" 'evilnc-comment-or-uncomment-lines)

;; C-x O navigates to previous window
(global-set-key (kbd "C-x O") 'previous-multiframe-window)

;; Single dired buffer
(autoload 'dired-single-buffer "dired-single" "" t)
(autoload 'dired-single-magic-buffer "dired-single" "" t)
(autoload 'dired-single-toggle-buffer-name "dired-single" "" t)
(defun my-dired-init ()
  "Bunch of stuff to run for dired, either immediately or when it's
        loaded."
  (define-key dired-mode-map (kbd "<return>") 'dired-single-buffer)
  (define-key dired-mode-map (kbd "<down-mouse-1>") 'dired-single-buffer)
  (define-key dired-mode-map "^"
    (lambda ()
      (interactive)
      (dired-single-buffer ".."))))
;; If dired's already loaded, then the keymap will be bound.
(if (boundp 'dired-mode-map)
    ;; We're good to go; Just add our bindings.
    (my-dired-init)
  ;; It's not loaded yet, so add our bindings to the load-hook.
  (add-hook 'dired-load-hook 'my-dired-init))

(add-hook 'dired-mode-hook
          (lambda ()
            ;; ;; Enable all commands
            ;; (setq disabled-command-function nil)

            ;; Auto-refresh dired on file change
            (auto-revert-mode)
            (setq-default auto-revert-interval 1)

            ;; Hide dired file permissions
            (require 'dired-details)
            (dired-details-install)
            (setq dired-details-hidden-string "")

            ;; Hide dired current directory (.)
            (require 'dired+)
            ;; Fix color theme
            (setq-default dired-omit-files-p t)
            (setq font-lock-maximum-decoration (quote ((dired-mode) (t . t)))
                  dired-omit-files (concat dired-omit-files "\\."))))

;; Highlight matching parentheses
(show-paren-mode 1)

;; Always follow symbolic links to version controlled files
(setq vc-follow-symlinks t)

;; Show line numbers
(global-linum-mode t)
;; With a space
(setq linum-format "%d "
      ;; Minibuffer line and column
      line-number-mode t
      column-number-mode t)

;; Folding
(when (not (string-match "unknown" system-configuration))
  (autoload 'hideshowvis-enable
    "hideshowvis"
    "Highlight foldable regions")

  (autoload 'hideshowvis-minor-mode
    "hideshowvis"
    "Will indicate regions foldable with hideshow in the fringe."
    'interactive)

  (dolist (hook '(emacs-lisp-mode-hook
                  lisp-mode-hook
                  scheme-mode-hook
                  c-mode-hook
                  c++-mode-hook
                  java-mode-hook
                  js-mode-hook
                  perl-mode-hook
                  php-mode-hook
                  tcl-mode-hook
                  vhdl-mode-hook
                  fortran-mode-hook
                  python-mode-hook))
    (add-hook hook
              (lambda ()
                ;; More syntax definitions
                (require 'fold-dwim)
                (hideshowvis-enable))))

  ;;
  ;; +/- fold buttons
  ;;

  (define-fringe-bitmap 'hs-marker [0 24 24 126 126 24 24 0])

  (defcustom hs-fringe-face 'hs-fringe-face
    "*Specify face used to highlight the fringe on hidden regions."
    :type 'face
    :group 'hideshow)

  (defface hs-fringe-face
    '((t (:foreground "#888" :box (:line-width 2 :color "grey75" :style released-button))))
    "Face used to highlight the fringe on folded regions"
    :group 'hideshow)

  (defcustom hs-face 'hs-face
    "*Specify the face to to use for the hidden region indicator"
    :type 'face
    :group 'hideshow)

  (defface hs-face
    '((t (:background "#ff8" :box t)))
    "Face to hightlight the ... area of hidden regions"
    :group 'hideshow)

  (defun display-code-line-counts (ov)
    (when (eq 'code (overlay-get ov 'hs))
      (let* ((marker-string "*fringe-dummy*")
             (marker-length (length marker-string))
             (display-string (format "(%d)..." (count-lines (overlay-start ov) (overlay-end ov))))
             )
        (overlay-put ov 'help-echo "Hiddent text. C-c,= to show")
        (put-text-property 0 marker-length 'display (list 'left-fringe 'hs-marker 'hs-fringe-face) marker-string)
        (overlay-put ov 'before-string marker-string)
        (put-text-property 0 (length display-string) 'face 'hs-face display-string)
        (overlay-put ov 'display display-string))))

  (setq hs-set-up-overlay 'display-code-line-counts))

;; Font: Monaco
(set-frame-font "Monaco")
;; Font size: 10pt
(set-face-attribute 'default nil :height
                    (if (eq system-type 'darwin)
                        120
                        80))

;; .emacs
(add-to-list 'auto-mode-alist '("emacs$" . emacs-lisp-mode))
;; .vimrc
(add-to-list 'auto-mode-alist '(".vim\\(rc\\)?$" . vimrc-mode))
;; Markdown
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
;; MS-DOS .BAT files
(autoload 'ntcmd-mode "ntcmd" "" t)
(add-to-list 'auto-mode-alist '("\\.bat\\'" . ntcmd-mode))
;; F#
(autoload 'fsharp-mode "fsharp-mode" "Major mode for editing F# code." t)
(autoload 'run-fsharp "inf-fsharp" "Run an inferior F# process." t)
(add-to-list 'auto-mode-alist '("\\.fs[iylx]?$" . fsharp-mode))
;; D
(autoload 'd-mode "d-mode" "" t)
(add-to-list 'auto-mode-alist '("\\.d\\'" . d-mode))
;; Mozart/Oz
(autoload 'oz-mode "oz" "Major mode for interacting with Oz code." t)
(add-to-list 'auto-mode-alist '("\\.oz\\'" . oz-mode))
;; Work around broken ruby-electric-brace.
(add-hook 'ruby-mode-hook
          (lambda ()
            (define-key ruby-mode-map "{" nil)
            (define-key ruby-mode-map "}" nil)))
;; We're Ruby, too!
(dolist (extension
         '("\\.rake$"
           "Rakefile$"
           "\\.gemspec$"
           "\\.ru$"
           "Gemfile$"
           "Guardfile$"))
  (add-to-list 'auto-mode-alist (cons extension 'ruby-mode)))
;; We're YAML, too!
(autoload 'yaml-mode "yaml-mode" "" t)
(add-to-list 'auto-mode-alist '("\\.reek\\'" . yaml-mode))
;; We're JavaScript, too!
(add-to-list 'auto-mode-alist '("\\.jshintrc\\'" . js-mode))

;; Monokai
(when window-system
    (load-theme 'monokai t))

;; ERB/EJS
(require 'mmm-auto)
(setq mmm-global-mode 'auto)
(mmm-add-mode-ext-class 'html-erb-mode "\\.erb\\'" 'erb)
(mmm-add-mode-ext-class 'html-erb-mode "\\.ejs\\'" 'ejs)
(mmm-add-mode-ext-class 'html-erb-mode nil 'html-js)
(mmm-add-mode-ext-class 'html-erb-mode nil 'html-css)
(add-to-list 'auto-mode-alist '("\\.erb\\'" . html-erb-mode))
(add-to-list 'auto-mode-alist '("\\.ejs\\'"  . html-erb-mode))

;; Default to Unix LF line endings
(setq default-buffer-file-coding-system 'utf-8-unix
      ;; Soft tabs
      indent-tabs-mode nil
      ;; 2 spaces
      tab-width 2
      sws-tab-width 2
      ;; And JavaScript
      js-indent-level 2)

;; And Erlang
(autoload 'erlang-mode "erlang" "" t)
(add-to-list 'auto-mode-alist '("\\.erl\\'" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.escript\\'" . erlang-mode))
(add-hook 'erlang-mode-hook
          (lambda ()
            (setq erlang-indent-level tab-width)))

;; And Haskell
(autoload 'haskell-mode "haskell-mode" "" t)
(add-to-list 'auto-mode-alist '("\\.hs\\'" . haskell-mode))
(add-to-list 'auto-mode-alist '("\\.lhs\\'" . haskell-mode))
(add-hook 'haskell-mode-hook
          (lambda ()
            (turn-on-haskell-indentation)
            (setq indent-tabs-mode nil
                  tab-width tab-width)))

;; If mark exists, indent rigidly.
;; Otherwise, insert a hard or soft tab indentation.
(defun traditional-indent ()
  (interactive)
  (if mark-active
    (indent-rigidly (region-beginning) (region-end) tab-width)
    (indent-to-column tab-width)))
;; Inverse.
(defun traditional-outdent ()
  (interactive)
  (if mark-active
    (indent-rigidly (region-beginning) (region-end) (* tab-width -1))
    (delete-backward-char tab-width)))

;; Block indent for Markdown
(add-hook 'markdown-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil
                  tab-width 4)
            (define-key markdown-mode-map (kbd "<tab>") 'traditional-indent)
            (define-key markdown-mode-map (kbd "<S-tab>") 'traditional-outdent)))

;; And PostScript
(add-hook 'ps-mode-hook
          (lambda () (setq ps-mode-tab tab-width)))
;; And Mozart/Oz
(add-hook 'oz-mode-hook
          (lambda () (setq oz-indent-chars tab-width)))
;; But not Makefiles
(defun hard-tabs ()
  (setq-default indent-tabs-mode t)
  (setq indent-tabs-mode t
        tab-width 2))
(add-hook 'makefile-mode-hook 'hard-tabs)
(add-hook 'makefile-gmake-mode-hook 'hard-tabs)
(add-hook 'makefile-bsdmake-mode-hook 'hard-tabs)

;; Convert hard tabs to spaces on save
(add-hook 'before-save-hook
          (lambda ()
            ;; But not Makefiles
            (if (member major-mode '(makefile-mode
                                     makefile-gmake-mode
                                     makefile-bsdmake-mode))
              (tabify (point-min) (point-max))
              (untabify (point-min) (point-max)))))
;;              (indent-region (point-min) (point-max)))))

;; Fix C family autoindent
;;
;; K&R style, and
;; Line up parentheses as well
(setq gangnam-style
  '((c-basic-offset . tab-width)
    (c-comment-only-line-offset . 0)
    (c-offsets-alist
      (arglist-close . c-lineup-close-paren)
      (statement-block-intro . +)
      (knr-argdecl-intro . 0)
      (substatement-open . 0)
      (substatement-label . 0)
      (label . 0)
      (statement-cont . +))))
(add-hook 'c-mode-common-hook
  (lambda ()
    (c-add-style "gangnam-style" gangnam-style t)))
;; Dart, too
(autoload 'dart-mode "dart-mode" "" t)
(add-to-list 'auto-mode-alist '("\\.dart\\'" . dart-mode))
(add-hook 'dart-mode-hook
  (lambda ()
    (c-add-style "dart" gangnam-style t)))

;; File tabs
(when window-system
    (require 'tabbar)
    (tabbar-mode 1)
    ;; CUA
    (global-set-key [C-S-tab] 'tabbar-backward-tab)
    (global-set-key [C-tab] 'tabbar-forward-tab)
    ;; Single tab group
    (setq tabbar-buffer-groups-function (lambda () '("group"))))

;; rgrep/lgrep ignore more file types
(eval-after-load "grep"
  '(progn
    (add-to-list 'grep-find-ignored-files "node_modules")))