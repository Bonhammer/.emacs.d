
;; http://pages.sachachua.com/.emacs.d/Sacha.html#orgfe5d909
;; http://doc.norang.ca/org-mode.html#Setup

(use-package org
:ensure t
:config
(progn
	;; config stuff
	)
:bind
;; ("C-c C-b" . org-mark-ring-goto)
)

;;==========================================================
;;      FILES
;;==========================================================

(defvar org-directory)
(setq org-directory (concat notes-dir "/org"))
(global-set-key (kbd "<f9> u")
								'(lambda ()
									 (interactive)
									 (setq org-agenda-files
												 (append
													(list org-directory)
													(file-expand-wildcards (concat org-directory "/*/*.org"))))
									 (message "org-agenda-files updated")
									 ))
;; (if (eq org-agenda-files nil)						; FIXME
;; 		()
;; 	())

;; ;; Doing this at every start-up is maybe not a good idea:
;; (setq org-agenda-files
;; 			(append
;; 			 (list org-directory)
;; 			 (file-expand-wildcards (concat org-directory "/*/*.org"))))

;; set refile targets to move entries inside org-agenda 
(setq org-refile-targets '(
													 (nil :maxlevel . 2)             ; refile to headings in the current buffer
													 (org-agenda-files :maxlevel . 2) ; refile to any of these files
													 ))

;;==========================================================
;;      GENERAL APPEARANCE
;;==========================================================

(font-lock-add-keywords 'org-mode
                        '(("^ +\\([-*]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

(add-hook 'org-mode-hook (lambda ()
													 (variable-pitch-mode t)
													 ;; (text-scale-increase 0.5)
													 ))

;; (set-face-attribute 'org-block-background nil :inherit 'fixed-pitch)
(custom-set-variables
 '(org-ref-label-color "magenta")
 '(org-ref-ref-color "Deepskyblue1")
 )
(custom-set-faces
 '(org-done ((t (:overline t))))
 '(org-todo ((t (:overline t))))
 '(org-block-background ((t (:inherit fixed-pitch :background "#3E3D31"))))
 '(org-block-begin-line ((t (:underline t))))
 '(org-block-end-line  ((t (:overline t))))
 '(org-level-1 ((t (:inherit outline-1 :overline t :height 1.5))))
 '(org-level-2 ((t (:inherit outline-2 :overline t :height 1.25))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.1))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.0))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.0))))
 )

(with-eval-after-load 'org
  (set-face-attribute 'org-table nil :inherit 'fixed-pitch)
	(set-face-attribute 'org-verbatim nil :inherit 'fixed-pitch :background "#3E3D31")
	(set-face-attribute 'org-latex-and-related nil :inherit 'fixed-pitch :background "#3E3D31")
	(set-face-attribute 'org-link nil :inherit 'fixed-pitch)
	(set-face-attribute 'org-date nil :inherit 'fixed-pitch)

	)

(setq org-hide-emphasis-markers t)

;; nicer bullets
(use-package org-bullets
	:ensure t
	:init
	(setq org-bullets-bullet-list
				'("◉" "◎" "○" "●" "►" "♦" "◇"))
	:config 
	(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
	)

;; folding symbol
(setq org-ellipsis " ▼")

;; replace HTML/LaTeX code by UTF-8 characters (see org-pretty-entities for an enumeration)
(setq org-pretty-entities t)


;;==========================================================
;;      MODULES
;;==========================================================

;; ;; See http://orgmode.org/worg/org-contrib/
;; (setq org-modules '( ;; org-bbdb
;;                       ;; org-gnus
;;                       ;; org-drill
;;                       ;; org-info
;;                       ;; org-jsinfo
;;                       ;; org-habit
;;                       ;; org-irc
;;                       ;; org-mouse
;;                       ;; org-protocol
;;                       ;; org-annotate-file
;;                       ;; org-eval
;;                       ;; org-expiry
;;                       ;; org-interactive-query
;;                       ;; org-man
;;                       ;; org-collector
;;                       ;; org-panel
;;                       ;; org-screen
;;                       ;; org-toc
;; 											))
;; (eval-after-load 'org
;;  '(org-load-modules-maybe t))
;; (setq org-expiry-inactive-timestamps t)

;; selection
(setq org-support-shift-select t)

;; source blocks
(setq org-src-fontify-natively t)

;; todo lists
(setq org-enforce-todo-dependencies t)

;; links
(setq org-return-follows-link t)

;; block
(setq org-hide-block-startup t) 				; hide blocks at startup

;; indent automatically
(add-hook 'org-mode-hook 'org-indent-mode)

;; support for inline tasks
(load "org-inlinetask")
(define-key org-mode-map (kbd "C-c C-x C-t") 'org-inlinetask-insert-task)

;; LaTeX support
(org-babel-do-load-languages 'org-babel-load-languages '((latex . t)))
(setq org-highlight-latex-and-related '(latex script entities)) ; inline sytax highlighting
;; (add-to-list 'org-latex-packages-alist '("" "tikz" t))					; unfortunately this breaks the color of fonts in inline previews
;; (add-to-list 'org-latex-packages-alist '("" "forest" t))
(plist-put org-format-latex-options :scale 1.3) ; scale inline PNGs

;; org-ref
;; (setq org-ref-completion-library 'org-ref-ivy-cite) ; must appear before org-ref
(use-package org-ref
	:ensure t
	:after org
	:init
	(require 'org-ref) 										; don't know why I need this
	(setq reftex-default-bibliography '((concat home-directory "/Dropbox/Forschung/timm-bib.bib"))) ; FIXME
	(setq org-ref-default-bibliography (concat home-directory "/Dropbox/Forschung/timm-bib.bib")
			;; org-ref-bibliography-notes "~/Dropbox/bibliography/notes.org"
				org-ref-pdf-directory (concat home-directory "/owncloud/Bib")
				)
	:config
	:bind (:map org-mode-map
							("C-c ]" . org-ref-helm-insert-cite-link)
							("C-c )" . org-ref-helm-insert-ref-link)
							("C-c (" . org-ref-helm-insert-label-link))
)

;; http://eschulte.github.io/babel-dev/DONE-integrate-plantuml-support.html
(setq org-plantuml-jar-path
      (expand-file-name "plantuml.jar" org-directory))
(org-babel-do-load-languages  'org-babel-load-languages '((plantuml . t)))

;; spell checking
;; ispell
(add-to-list 'ispell-skip-region-alist '(":\\(PROPERTIES\\|LOGBOOK\\):" . ":END:"))
(add-to-list 'ispell-skip-region-alist '("#\\+BEGIN_SRC" . "#\\+END_SRC"))
;; flyspell
;; http://emacs.stackexchange.com/a/9347/12336
;; NO spell check for embedded snippets
(defadvice org-mode-flyspell-verify (after org-mode-flyspell-verify-hack activate)
  (let ((rlt ad-return-value)
        (begin-regexp "^[ \t]*#\\+begin_\\(src\\|html\\|latex\\)")
        (end-regexp "^[ \t]*#\\+end_\\(src\\|html\\|latex\\)")
        old-flag
        b e)
    (when ad-return-value
      (save-excursion
        (setq old-flag case-fold-search)
        (setq case-fold-search t)
        (setq b (re-search-backward begin-regexp nil t))
        (if b (setq e (re-search-forward end-regexp nil t)))
        (setq case-fold-search old-flag))
      (if (and b e (< (point) e)) (setq rlt nil)))
    (setq ad-return-value rlt)))

;; show notifications of agenda events
(use-package org-alert
	:ensure t
	)

;;==========================================================
;;      TAGS
;;==========================================================

(setq org-tag-alist '((:startgroup . nil)
											("@work" . ?w)
											(:grouptags . nil)
											("admin" . ?a)
											("teaching" . ?t)
											("research" . ?r)
											(:endgroup . nil)

											(:startgroup . nil)
											("research" . ?r)
											(:grouptags . nil)
											("mwe" . nil)									
											("parsing" . nil)
											("linguistics" . nil)
											("formalisms" . nil)
											("philosophy" . nil)
											("logic" . nil)
											("maths" . nil)
											("computerScience" . nil)
											("xmg" . nil)											
											(:endgroup . nil)

											(:startgroup . nil)
											("science" . ?h)
											(:grouptags . nil)
											("linguistics" . nil)
											("computationalLinguistics" . nil)
											("philosophy" . nil)
											("logic" . nil)
											("maths" . nil)
											("computerScience" . nil)
											(:endgroup . nil)

											(:startgroup . nil)
											("linguistics" . ?h)
											(:grouptags . nil)
											("syntax" . nil)
											("semantics" . nil)
											("pragmatics" . nil)
											("phonology" . nil)
											("morphology" . nil)
											("corpora" . nil)
											(:endgroup . nil)

											(:startgroup . nil)
											("computationalLinguistics" . ?h)
											(:grouptags . nil)
											("parsing" . nil)
											("generation" . nil)
											("formalisms" . nil)
											("corpora" . nil)
											("speechRecognition" . nil)
											("machineLearning" . nil)
											(:endgroup . nil)

											
											(:startgroup . nil)
											("@home" . ?h)
											(:grouptags . nil)
											("spenden" . nil)
											(:endgroup . nil)

											(:startgroup . nil)
											("software" . ?h)
											(:grouptags . nil)
											("programming" . nil)
											("nlp" . nil)
											("os" . nil)
											("xmg" . nil)											
											(:endgroup . nil)

											(:startgroup . nil)
											("programming" . ?p)
											(:grouptags . nil)
											("emacs" . ?m)
											("latex" . ?x)
											("langsci" . ?l)
											("python" . ?y)
											("javascript" . ?j)
											("perl" . nil)
											("php" . nil)
											("shellscript" . nil)											
											(:endgroup . nil)
											))


;;==========================================================
;;      TABLES
;;==========================================================

;; http://emacs.stackexchange.com/a/28298/12336
(defun org-table-goto-col-beginning ()
  "Go to beginning of current column and return `point'."
  (interactive)
  (assert (org-table-p) "Not in org-table.")
  (org-table-align)
  (let ((col (org-table-current-column)))
    (goto-char (org-table-begin))
    (org-table-goto-column col))
  (point))

(defun org-table-col-beginning ()
  "Return beginning position of current column."
  (save-excursion
    (org-table-goto-col-beginning)))

(defun org-table-goto-col-end ()
  "Goto end of current column and return `point'."
  (interactive)
  (assert (org-table-p) "Not in org-table.")
  (org-table-align)
  (let ((col (org-table-current-column)))
    (goto-char (1- (org-table-end)))
    (org-table-goto-column col)
    (skip-chars-forward "^|"))
  (point))

(defun org-table-col-end ()
  "Return end position of current column."
  (save-excursion
    (org-table-goto-col-end)))

(defun org-table-select-col ()
  "Select current column."
  (interactive)
  (set-mark (org-table-col-beginning))
  (org-table-goto-col-end))

(defun org-table-copy-col ()
  "Copy current column."
  (interactive)
  (save-excursion
    (org-table-copy-region (org-table-goto-col-beginning)
													 (org-table-goto-col-end))))


;;==========================================================
;;      KEYS
;;==========================================================

(global-set-key (kbd "<f9> c") 'org-goto-calendar)
(global-set-key (kbd "<f9> a") 'org-agenda-list)
(global-set-key (kbd "<f9> t") 'org-todo-list)
(global-set-key (kbd "C-<f9>") 'org-cycle-agenda-files)
(global-set-key (kbd "<f9> s") 'org-search-view)
(global-set-key (kbd "<f9> f") 'org-search-view)
(global-set-key (kbd "<f9> l") 'org-tags-view)
(global-set-key (kbd "<f9> r") 'org-reload)
(global-set-key (kbd "<f9> w")
								(lambda() (interactive)(find-file (concat org-directory "/forschung/wip.org"))))
(global-set-key (kbd "<f9> n")
								(lambda() (interactive)(find-file (concat org-directory "/notes.org"))))

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-<tab>") nil ))
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "S-<up>") nil ))
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "S-<down>") nil ))
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c C-f") 'org-footnote-action ))
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c C-x C-b") 'org-tree-to-indirect-buffer ))

;; (bind-key "C-c r" 'org-capture)
(bind-key "C-c a" 'org-agenda)
(bind-key "C-c l" 'org-store-link)
;; (bind-key "C-c L" 'org-insert-link-global)
;; (bind-key "C-c O" 'org-open-at-point-global)
;; (bind-key "<f9> <f9>" 'org-agenda-list)
;; (bind-key "<f9> n" 'org-cycle-agenda-files)
;; (bind-key "<f9> <f8>" (lambda () (interactive) (org-capture nil "r")))

;; (with-eval-after-load 'org
;;   (bind-key "C-M-w" 'append-next-kill org-mode-map)
;;   (bind-key "C-TAB" 'org-cycle org-mode-map)
;;   (bind-key "C-c v" 'org-show-todo-tree org-mode-map)
;;   (bind-key "C-c C-r" 'org-refile org-mode-map)
;;   (bind-key "C-c R" 'org-reveal org-mode-map)

;; (with-eval-after-load 'org-agenda
;;   (bind-key "i" 'org-agenda-clock-in org-agenda-mode-map))


;;==========================================================
;;      CAPTURE TEMPLATES
;;==========================================================

(setq org-capture-templates
      '(("t" "Todo" entry (file (concat org-directory "/todo.org"))
         "* TODO %?\t%^g\n CREATED: %U\n About region:%i\n %a")
        ("n" "Note" entry (file+datetree (concat org-directory "/notes.org"))
				 "* %?\t%^g\n CREATED: %U\n About region:%i\n %a")
				("c" "Code" entry (file (concat org-directory "/code.org"))
         "* %?\t%^g\n#+BEGIN_SRC %^{language}\n\n#+END_SRC\n CREATED: %U\n About region:%i\n %a")
				))

(global-set-key (kbd "<f9> <f9>") 'org-capture)
;; (global-set-key (kbd "<f9> <f9> t") (lambda () (interactive) (org-capture nil "t")))


;;==========================================================
;;      TODO KEYWORDS
;;==========================================================

;; (setq org-todo-keywords
;;       (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
;;               (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" "PHONE" "MEETING"))))

;; (setq org-todo-keyword-faces
;;       (quote (("TODO" :foreground "red" :weight bold)
;;               ("NEXT" :foreground "blue" :weight bold)
;;               ("DONE" :foreground "forest green" :weight bold)
;;               ("WAITING" :foreground "orange" :weight bold)
;;               ("HOLD" :foreground "magenta" :weight bold)
;;               ("CANCELLED" :foreground "forest green" :weight bold)
;;               ("MEETING" :foreground "forest green" :weight bold)
;;               ("PHONE" :foreground "forest green" :weight bold))))


(provide 'setup-orgmode)