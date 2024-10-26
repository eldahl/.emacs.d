(add-to-list 'load-path "~/.emacs.d/scripts/")
(require 'elpaca-setup)

(setq backup-directory-alist '(~/.emacs.d/backup-files))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq inhibit-startup-message t)    
(delete-selection-mode 1) ;; Enable overwriting selected text
(electric-indent-mode -1) ;; Disable indention behaviour
;;(electric-pair-mode 1)  ;; Add second element of a pair automatically, such as parentheses pairs.

;; The following prevents <> from auto-pairing when electric-pair-mode is on.
;; Otherwise, org-tempo is broken when you try to <s TAB...
(add-hook 'org-mode-hook (lambda ()
    (setq-local electric-pair-inhibit-predicate
	    `(lambda (c)
	(if (char-equal c ?<) t (,electric-pair-inhibit-predicate c))))))
(global-auto-revert-mode t)                      ;; Automatically show changes if the file has changed
(global-display-line-numbers-mode 1)             ;; Line numbers
(setq display-line-numbers 'relative)            ;; Relative line numbers
(global-visual-line-mode t)                      ;; Enable truncated lines
(setq scroll-step 1 scroll-conservatively 10000) ;; Smooth scrolling
(setq org-edit-src-content-indentation 0)        ;; set src block automatic indent to 0 isntead of 2.
(setq ring-bell-fucntion 'ignore)                ;; Turn off the annoyting ringing when a key press is not valid
(global-hl-line-mode 1)                          ;; Highlight line of cursor
(custom-set-faces                                ;; Set color of cursor highligh line
  '(hl-line ((t (:background "#1a1d21")))))
(add-to-list 'default-frame-alist '(alpha-background . 80))

(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode)
)

(use-package evil
    :ensure t
    :init
    (setq evil-want-integration t
	evil-want-keybinding nil
	evil-vsplit-window-right t
	evil-vsplit-window-below t
	evil-undo-system 'undo-redo)
    :config
    (evil-mode 1))

(use-package evil-collection
    :after evil
    :ensure t
    :config
    (evil-collection-init))

(use-package toc-org
    :ensure t
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(eval-after-load 'org-indent '(diminish 'org-indent-mode))

(use-package doom-themes
    :config
    (setq doom-themes-enable-bold t
	doom-themes-enable-italics t)
    (load-theme 'doom-one t)
    (doom-themes-org-config))

(use-package general
    :config
    (general-evil-setup)
    (general-define-key
	:states '(normal visual insert emacs)
	:keymaps 'override
	"C-n" '(neotree-toggle :wk "Toggle NeoTree file browser")
    )
    (general-create-definer cw/leader-keys
    :states '(normal visual insert emacs)
    :keymaps 'override
    :prefix "SPC" ;; Set leader key
    :global-prefix "M-SPC") ;; Access leader in insert mode
    
    (cw/leader-keys
    "r" '(:ignore t :wk "Reloading config")
    "r c" '((lambda () (interactive)
		    (load-file "~/.emacs.d/init.el")
		    (ignore (elpaca-process-queues))) :wk "Reload buffer"))
    (cw/leader-keys
    "f" '(:ignore t :wk "Config")
    "f c" '((lambda () (interactive)
		    (find-file "~/.emacs.d/config.org"))
		    :wk "Open emacs config.org"))
    (cw/leader-keys
    "n" '(:ignore t :wk "Git")
    "n g" '(magit :wk "Open Magit UI"))

)

(use-package which-key
  :init
    (which-key-mode 1)
  :diminish
  :config
  (setq which-key-side-window-location 'bottom
      which-key-sort-order #'which-key-key-order-alpha
      which-key-allow-imprecise-window-fit nil
      which-key-sort-uppercase-first nil
      which-key-add-column-padding 1
      which-key-max-display-columns nil
      which-key-min-display-lines 6
      which-key-side-window-slot -10
      which-key-side-window-max-height 0.25
      which-key-idle-delay 0.8
      which-key-max-description-length 25
      which-key-allow-imprecise-window-fit nil
      which-key-separator " → " )
    (which-key-mode))

(use-package zig-mode)

(use-package neotree
  :config
  (setq neo-smart-open t
        neo-show-hidden-files t
        neo-window-width 35
        neo-window-fixed-size nil
        neo-window-position `right
        inhibit-compacting-font-caches t
        projectile-switch-project-action 'neotree-projectile-action)
        neo-keymap-style 'concise
        ;; truncate long file names in neotree
        (add-hook 'neo-after-create-hook
           #'(lambda (_)
               (with-current-buffer (get-buffer neo-buffer-name)
                 (setq truncate-lines t)
                 (setq word-wrap nil)
                 (make-local-variable 'auto-hscroll-mode)
                 (setq auto-hscroll-mode nil)))))

(set-face-attribute 'default nil
  :font "LiterationMono Nerd Font"
  :height 110
  :weight 'medium)
(set-face-attribute 'variable-pitch nil
  :font "LiterationMono Nerd Font"
  :height 120
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "LiterationMono Nerd Font"
  :height 110
  :weight 'medium)
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)
(add-to-list 'default-frame-alist '(font . "LiterationMono Nerd Font"))
(setq-default line-spacing 0.12)

(use-package transient)

(defun +elpaca-unload-seq (e)
  (and (featurep 'seq) (unload-feature 'seq t))
  (elpaca--continue-build e))

(defun +elpaca-seq-build-steps ()
  (append (butlast (if (file-exists-p (expand-file-name "seq" elpaca-builds-directory))
                       elpaca--pre-built-steps elpaca-build-steps))
          (list '+elpaca-unload-seq 'elpaca--activate-package)))

(use-package seq :ensure `(seq :build ,(+elpaca-seq-build-steps)))
(use-package magit 
  :after seq
  :ensure t)
