

;;==========================================================
;;      GENERAL CONFIGURATION
;;==========================================================

;; automatically update buffers when files change
(global-auto-revert-mode t)

;; visible bell
(setq visible-bell t)
(setq ring-bell-function (lambda ()
                           (invert-face 'mode-line)
                           (run-with-timer 0.05 nil 'invert-face 'mode-line)))

;; delete marked text on typing
(delete-selection-mode t)

;; use tabs for indent
(setq-default tab-width 2)
(setq-default indent-tabs-mode t)

;; scrolling
(setq scroll-step            1
      scroll-conservatively  10000)
;; autoscroll compilation output
(setq compilation-scroll-output t)
;; scroll to the first/last line
(setq scroll-error-top-bottom t)


;; show vertical line per indentation level 
(use-package highlight-indent-guides
	:ensure t
	:config
	(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
	(setq highlight-indent-guides-method 'character)
	)



;;==========================================================
;;      AUTOCOMPLETE
;;==========================================================

;; yasnippet (before auto-complete)
(use-package yasnippet
	:ensure t
	:config (yas-global-mode 1))

;; ;; auto-complete, sequence is important
;; (require 'auto-complete)
;; (require 'auto-complete-auctex)
;; (require 'auto-complete-config)
;; (ac-config-default)
;; (setq ac-auto-show-menu t)
;; (setq ac-auto-show-menu 1)
;; (global-auto-complete-mode 1)
;; ;; (add-to-list 'ac-modes 'latex-mode)     ; activate auto-complete for latex <modes (AUCTeX or Emacs' builtin one).
;; (add-hook 'latex-mode-hook (function (lambda ()
;; 																					(ac-source-yasnippet))))

;; company
(use-package company
	:ensure t
	:config
	(use-package company-auctex
		:ensure t
		:config (company-auctex-init))
	(add-hook 'after-init-hook 'global-company-mode)
	;; yasnippet integration
	(defvar company-mode/enable-yas t
		"Enable yasnippet for all backends.")
	(defun company-mode/backend-with-yas (backend)
		(if (or (not company-mode/enable-yas)
						(and (listp backend) (member 'company-yasnippet backend)))
				backend
			(append (if (consp backend) backend (list backend))
							'(:with company-yasnippet))))
	(setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))
	;; some general variables
	(setq company-idle-delay 0.3
				company-minimum-prefix-length 1
				company-selection-wrap-around t
				;; company-show-numbers t
				company-dabbrev-downcase nil
				company-auto-complete nil
				company-transformers '(company-sort-by-occurrence))
	(add-hook 'eshell-mode-hook '(lambda () (setq company-idle-delay 0)))
	(eval-after-load 'company
	  '(progn
	     (define-key company-active-map (kbd "<tab>") 'company-complete-selection)
			 (define-key company-active-map (kbd "<return>") nil)
			 (define-key company-active-map (kbd "RET") nil)
	     ;; (define-key company-active-map (kbd "<tab>") 'company-complete-common)  ; Insert the common part of all candidates.  
	     ;; (define-key company-active-map (kbd "<tab>") 'company-select-next))
		))
	(use-package company-flx
		:ensure t
		:config
		(company-flx-mode +1))
	;; add company to org-mode
 	(add-to-list 'company-backends 'company-capf)
	(defun add-pcomplete-to-capf ()
		(add-hook 'completion-at-point-functions 'pcomplete-completions-at-point nil t))
	(add-hook 'org-mode-hook #'add-pcomplete-to-capf)
	)


;;==========================================================
;;      SYNTAX CHECK
;;==========================================================

;; flycheck
(use-package flycheck
	:ensure t
	:config
	(global-flycheck-mode t)
	(add-hook 'text-mode-hook '(lambda ()(flycheck-mode 0)))
	)

;; flyspell
(require 'setup-flyspell)


;;==========================================================
;;      PAREN HANDLING
;;==========================================================

;; smartparens
(use-package smartparens
	:ensure t
	:config
	(use-package smartparens-config)
	(setq sp-autoescape-string-quote nil)
	(--each '(css-mode-hook
						restclient-mode-hook
						js-mode-hook
						java-mode-hook
						ruby-mode-hook
						emacs-lisp-mode-hook
						LaTeX-mode-hook
						bibtex-mode-hook
						shell-mode-hook
						TeX-mode-hook
						markdown-mode-hook
						org-mode-hook
						groovy-mode-hook
						scala-mode-hook)
		(add-hook it #'smartparens-mode))
	(require 'smartparens-latex)
	;; org-mode
	(sp-with-modes 'org-mode
		(sp-local-pair "*" "*" :actions '(insert wrap) :unless '(sp-point-after-word-p sp-point-before-word-p sp-point-at-bol-p sp-in-math-p) )
		(sp-local-pair "_" "_" :unless '(sp-point-after-word-p sp-point-before-word-p sp-in-math-p) )
		(sp-local-pair "/" "/" :unless '(sp-point-after-word-p sp-point-before-word-p sp-in-math-p) )
		(sp-local-pair "~" "~" :unless '(sp-point-after-word-p sp-point-before-word-p sp-in-math-p) )
		(sp-local-pair "=" "=" :unless '(sp-point-after-word-p sp-point-before-word-p sp-in-math-p) )
		(sp-local-pair "+" "+" :unless '(sp-point-after-word-p sp-point-before-word-p sp-in-math-p tl/sp-point-after-hash-p) )
		(sp-local-pair "$" "$" :unless '(sp-point-after-word-p sp-point-before-word-p) )
		(sp-local-pair "«" "»"))
	)
(defun tl/sp-point-after-hash-p (id action context)
  "Return t if point is after a hash, nil otherwise.
This predicate is only tested on \"insert\" action.
Its definition follows the one of sp-point-after-word-p."
  (when (eq action 'insert)
		(sp--looking-back-p (concat "\\(#\\)" (regexp-quote id)))))

;; jump to matching paren
(defun goto-match-paren (arg)
  "Go to the matching  if on (){}[], similar to vi style of % "
  (interactive "p")
  ;; first, check for "outside of bracket" positions expected by forward-sexp, etc.
  (cond ((looking-at "[\[\(\{]") (forward-sexp))
        ((looking-back "[\]\)\}]" 1) (backward-sexp))
        ;; now, try to succeed from inside of a bracket
        ((looking-at "[\]\)\}]") (forward-char) (backward-sexp))
        ((looking-back "[\[\(\{]" 1) (backward-char) (forward-sexp))
        (t nil)))
(global-set-key (kbd "C-M-m") 'goto-match-paren)
(global-set-key (kbd "M-(") 'sp-backward-sexp)
(global-set-key (kbd "M-)") 'sp-forward-sexp)
(global-set-key (kbd "M-m") 'goto-match-paren)
(global-set-key (kbd "M-[") 'sp-beginning-of-sexp)
(global-set-key (kbd "M-]") 'sp-end-of-sexp)
(global-set-key (kbd "M-DEL") nil)
(global-set-key (kbd "M-DEL M-[") 'sp-unwrap-sexp)

;; https://ebzzry.github.io/emacs-pairs.html
;; (defmacro def-pairs (pairs)
;;   `(progn
;;      ,@(loop for (key . val) in pairs
;;           collect
;;             `(defun ,(read (concat
;;                             "wrap-with-"
;;                             (prin1-to-string key)
;;                             "s"))
;;                  (&optional arg)
;;                (interactive "p")
;;                (sp-wrap-with-pair ,val)))))
;; (def-pairs ((paren        . "(")
;;             (bracket      . "[")
;;             (brace        . "{")
;;             (single-quote . "'")
;;             (double-quote . "\"")
;;             (back-quote   . "`")))
;; (global-set-key (kbd "C-[") 'wrap-with-brackets) ; TODO: find nice key bindings
;; (global-set-key (kbd "C-(") 'wrap-with-parens)
;; (global-set-key (kbd "C-{") 'wrap-with-braces)


;;==========================================================
;;      INDENTATION
;;==========================================================

;; auto-indent when yanking
;; https://www.emacswiki.org/emacs/AutoIndentation
(dolist (command '(yank yank-pop))
	(eval `(defadvice ,command (after indent-region activate)
					 (and (not current-prefix-arg)
								(member major-mode '(emacs-lisp-mode lisp-mode
																										 clojure-mode    scheme-mode
																										 haskell-mode    ruby-mode
																										 rspec-mode      python-mode
																										 c-mode          c++-mode
																										 objc-mode       latex-mode
																										 plain-tex-mode))
								(let ((mark-even-if-inactive transient-mark-mode))
									(indent-region (region-beginning) (region-end) nil))))))


;;==========================================================
;;      SELECTION
;;==========================================================

;; expand-region (intelligent selection)
(use-package expand-region
	:ensure t
	:bind ("C-+" . er/expand-region)
	)

;; ;; copy mouse selection to kill-ring
;; (setq mouse-drag-copy-region t)


;;==========================================================
;;      CURSOR PLACEMENT 
;;==========================================================

;; adds ace jump mode
(use-package ace-jump-mode
	:ensure t
	:bind 
	("C-c SPC" . ace-jump-mode))

;; multiple cursors
(use-package multiple-cursors
	:ensure t
	:bind
	("C-S-c C-S-c" . mc/edit-lines)
	("C->" . mc/mark-next-like-this)
	("C-<" . mc/mark-previous-like-this)
	("C-c C-<" . mc/mark-all-like-this)
	)

;; cursor position history (LOCAL)
(require 'point-undo)
(global-set-key [M-left] 'point-undo)
(global-set-key [M-right] 'point-redo)
(global-set-key (kbd "M-j") 'point-undo)
(global-set-key (kbd "M-k") 'point-redo)
;; focus on line-based jumps
;; http://emacs.stackexchange.com/a/28078/12336
(defvar point-undo-ring-length 100)
(defvar point-undo-ring (make-ring point-undo-ring-length))
(make-variable-buffer-local 'point-undo-ring)
(defvar point-redo-ring (make-ring point-undo-ring-length))
(make-variable-buffer-local 'point-redo-ring)
(defun point-undo-pre-command-hook ()
  "Save positions before command."
  (unless (or (eq this-command 'point-undo)
              (eq this-command 'point-redo))
    (let ((line (line-number-at-pos)))
      (when (eq line (cdr (nth 0 (ring-elements point-undo-ring))))
        (ring-remove point-undo-ring 0))
      (ring-insert point-undo-ring (cons (point) line))
      (setq point-redo-ring (make-ring point-undo-ring-length)))))
(add-hook 'pre-command-hook 'point-undo-pre-command-hook)
(defun point-undo-doit (ring1 ring2)
  "ring1, ring2 = {point-undo-ring, point-redo-ring}"
  (condition-case nil
      (progn
        (goto-char (car (nth 0 (ring-elements ring1)))) 
        (ring-insert ring2 (ring-remove ring1 0)))
    (error nil)))
(defun point-undo ()
  "Undo position."
  (interactive)
  (point-undo-doit point-undo-ring point-redo-ring))
(defun point-redo ()
  "Redo position."
  (interactive)
  (when (or (eq last-command 'point-undo)
            (eq last-command 'point-redo))
    (point-undo-doit point-redo-ring point-undo-ring)))



;; cursor position undo history
(use-package goto-last-change
	:ensure t
	:bind
	("M-_" . goto-last-change))


;;==========================================================
;;      UNDO, COMMENT & REMOVE
;;==========================================================

;; visualize the undo history
(use-package undo-tree
	:ensure t
  :diminish undo-tree-mode
  :config
  (progn
    (global-undo-tree-mode)
    (setq undo-tree-visualizer-timestamps t)
    (setq undo-tree-visualizer-diff t)))

;; critical markup
(use-package cm-mode
	:ensure t
	:config
	(setq-default cm-author "TL"))

;; remove newlines from region
;; http://stackoverflow.com/a/5194503
(defun remove-newlines-in-region ()
  "Removes all newlines in the region."
  (interactive)
  (save-restriction
    (narrow-to-region (point) (mark))
    (goto-char (point-min))
    (while (search-forward "\n" nil t) (replace-match " " nil t))))

(defun remove-newline ()
	(save-excursion 
		(search-forward "\n")
		(replace-match " ")))

(defun remove-newlines-or-blank-lines-dwim ()
	(interactive)
	(progn (if (use-region-p)
						 (remove-newlines-in-region)
					 (if (next-line-empty-p)
							 (delete-blank-lines)
						 (remove-newline)
					 ))))

(defun next-line-empty-p ()
  (save-excursion
		(next-line)
    (beginning-of-line)
    (looking-at "[[:space:]]*$")))


;; remove extra spaces from line or region (TODO)
(defun tl/remove-extra-spaces-dwim ()
	"Remove extra spaces in line or in region."
	(interactive)
	(if (region-active-p)
			(save-restriction
				(narrow-to-region (point) (mark))
				(save-excursion 
					(goto-char (point-min))
					(while (re-search-forward "[ ]+" nil t) (replace-match " " nil t))))
		(save-excursion
			(move-beginning-of-line nil)  					; FIXME: undo doesn't see save-excursion
			(while (re-search-forward "[ ]+" (line-end-position) t)
				(replace-match " "))))
	)


;;==========================================================
;;      TRACKING CHANGES
;;==========================================================

;; http://emacs-fu.blogspot.de/2009/05/tracking-changes.html
;; higlight changes in documents
(global-highlight-changes-mode t)
(setq highlight-changes-visibility-initial-state nil); initially hide
;; toggle visibility
(global-set-key (kbd "<f8>") 'highlight-changes-visible-mode) ;; changes
;; remove the change-highlight in region
(global-set-key (kbd "S-<f8>") 'highlight-changes-remove-highlight)
;; if you're not already using it for something else...
(global-set-key (kbd "<M-prior>") 'highlight-changes-next-change)
(global-set-key (kbd "<M-next>")  'highlight-changes-previous-change)
;; faces
(set-face-foreground 'highlight-changes nil)
(set-face-background 'highlight-changes "#916868")
(set-face-foreground 'highlight-changes-delete nil)
(set-face-background 'highlight-changes-delete "#916868")

;; http://stackoverflow.com/a/21084181/6452961
;; show mark in fringe
(eval-after-load "hilit-chg"
  '(progn
     (defvar highlight-fringe-mark 'filled-square
       "The fringe bitmap name marked at changed line.
Should be selected from `fringe-bitmaps'.")

     (defadvice hilit-chg-make-ov (after hilit-chg-add-fringe activate)
       (mapc (lambda (ov)
							 (if (overlay-get ov 'hilit-chg)
									 (let ((fringe-anchor (make-string 1 ?x)))
										 (put-text-property 0 1 'display
																				(list 'left-fringe highlight-fringe-mark)
																				fringe-anchor)
										 (overlay-put ov 'before-string fringe-anchor))
								 ))
						 (overlays-at (ad-get-arg 1))))))
;; remove highlights on save time
(add-hook 'after-save-hook
          (lambda ()
            (when highlight-changes-mode
              (save-restriction
                (widen)
                (highlight-changes-remove-highlight (point-min) (point-max))))))


;;==========================================================
;;     SWITCH BETWEEN BUFFERS
;;==========================================================

;; switching between buffers with C-tab
(use-package iflipb
	:ensure t
	:config
	(setq iflipb-wrap-around t)
	(setq iflipb-include-more-buffers t)
	:bind
	("<C-tab>" . iflipb-next-buffer))


;;==========================================================
;;     NARROWING
;;==========================================================

;; http://endlessparentheses.com/emacs-narrow-or-widen-dwim.html
(defun narrow-or-widen-dwim (p)
"Widen if buffer is narrowed, narrow-dwim otherwise.
Dwim means: region, org-src-block, org-subtree, or
defun, whichever applies first. Narrowing to
org-src-block actually calls `org-edit-src-code'.

With prefix P, don't widen, just narrow even if buffer
is already narrowed."
(interactive "P")
(declare (interactive-only))
(cond ((and (buffer-narrowed-p) (not p)) (widen))
			((region-active-p)
			 (narrow-to-region (region-beginning)
												 (region-end)))
			((derived-mode-p 'org-mode)
			 ;; `org-edit-src-code' is not a real narrowing
			 ;; command. Remove this first conditional if
			 ;; you don't want it.
			 (cond ((ignore-errors (org-edit-src-code) t)
							(delete-other-windows))
						 ((ignore-errors (org-narrow-to-block) t))
						 (t (org-narrow-to-subtree))))
			((derived-mode-p 'latex-mode)
			 (LaTeX-narrow-to-environment))
			(t (narrow-to-defun))))

;; This line actually replaces Emacs' entire narrowing
;; keymap, that's how much I like this command. Only
;; copy it if that's what you want.
(define-key ctl-x-map "n" #'narrow-or-widen-dwim)
(add-hook 'LaTeX-mode-hook
          (lambda ()
            (define-key LaTeX-mode-map "\C-xn"
              nil)))

;;==========================================================
;;      FILE BROWSER
;;==========================================================

;; use deer instead plain directory listing
(use-package ranger
	:ensure t
	:bind
	("C-x C-d" . deer))

;; open file from inside a buffer
(global-set-key (kbd "C-x f") 'find-file-at-point)


;;==========================================================
;;      KEYS
;;==========================================================

;; commenting
(global-set-key (kbd "C-;") 'comment-or-uncomment-region-or-line)
(eval-after-load "LaTeX-mode"
	'(define-key LaTeX-mode-map (kbd "C-;") 'comment-or-uncomment-region-or-line))
(eval-after-load "markdown-mode"
	'(define-key LaTeX-mode-map (kbd "C-;") 'comment-or-uncomment-region-or-line))
(defun comment-or-uncomment-region-or-line ()
  "Comments or uncomments the region or the current line if there's no active region."
  (interactive)
  (let (beg end)
    (if (region-active-p)
				(setq beg (region-beginning) end (region-end))
      (setq beg (line-beginning-position) end (line-end-position)))
    (comment-or-uncomment-region beg end)
    (next-line)))

;; delete line
;; (global-set-key (kbd "C-d C-o") 'delete-blank-lines) ; not allowed here, see underi-mode.el
;; (global-set-key (kbd "C-d C-m") 'delete-blank-lines)
(global-set-key (kbd "C-S-k") 'kill-whole-line)
;; (global-set-key (kbd "C-k") 'kill-sentence) ; too greedy
(global-set-key (kbd "C-S-d") 'kill-whole-line)

;; new line
(global-set-key (kbd "S-<return>") 'smart-open-line)
(global-set-key (kbd "C-x C-<return>") 'smart-open-line)
(global-set-key (kbd "C-S-<return>") 'smart-open-line-above)
(global-set-key (kbd "C-o") 'smart-open-line)
(global-set-key (kbd "C-S-o") 'smart-open-line-above)
;; http://emacsredux.com/blog/2013/03/26/smarter-open-line/
(defun smart-open-line ()
  "Insert an empty line after the current line.
Position the cursor at its beginning, according to the current mode."
  (interactive)
  (move-end-of-line nil)
  (newline-and-indent))
;; http://emacsredux.com/blog/2013/06/15/open-line-above/
(defun smart-open-line-above ()
  "Insert an empty line above the current line.
Position the cursor at it's beginning, according to the current mode."
  (interactive)
  (move-beginning-of-line nil)
  (newline-and-indent)
  (forward-line -1)
  (indent-according-to-mode))

;; center line
(global-set-key (kbd "C-S-l") 'recenter-top-bottom)

;; open untitled new buffer
(defun xah-new-empty-buffer ()
  "Open a new empty buffer.
URL `http://ergoemacs.org/emacs/emacs_new_empty_buffer.html'
Version 2015-06-12"
  (interactive)
  (let ((buf (generate-new-buffer "untitled")))
    (switch-to-buffer buf)
    (funcall (and initial-major-mode))
    (setq buffer-offer-save t)))
(global-set-key (kbd "<f7> <f7>") 'xah-new-empty-buffer)

;; copy/cut whole line or region
(global-set-key (kbd "C-w") 'xah-cut-line-or-region) ; cut
(global-set-key (kbd "M-w") 'xah-copy-line-or-region) ; copy
(defun xah-cut-line-or-region ()
  "Cut current line, or text selection.
When `universal-argument' is called first, cut whole buffer (respects `narrow-to-region').
URL `http://ergoemacs.org/emacs/emacs_copy_cut_current_line.html'
Version 2015-06-10"
  (interactive)
  (if current-prefix-arg
      (progn ; not using kill-region because we don't want to include previous kill
        (kill-new (buffer-string))
        (delete-region (point-min) (point-max)))
    (progn (if (use-region-p)
               (kill-region (region-beginning) (region-end) t)
             (kill-region (line-beginning-position) (line-beginning-position 2))))))
(defun xah-copy-line-or-region ()
  "Copy current line, or text selection.
When called repeatedly, append copy subsequent lines.
When `universal-argument' is called first, copy whole buffer (respects `narrow-to-region').
URL `http://ergoemacs.org/emacs/emacs_copy_cut_current_line.html'
Version 2016-06-18"
  (interactive)
  (let (-p1 -p2)
    (if current-prefix-arg
        (setq -p1 (point-min) -p2 (point-max))
      (if (use-region-p)
          (setq -p1 (region-beginning) -p2 (region-end))
        (setq -p1 (line-beginning-position) -p2 (line-end-position))))
    (if (eq last-command this-command)
        (progn
          (progn ; hack. exit if there's no more next line
            (end-of-line)
            (forward-char)
            (backward-char))
          ;; (push-mark (point) "NOMSG" "ACTIVATE")
          (kill-append "\n" nil)
          (kill-append (buffer-substring-no-properties (line-beginning-position) (line-end-position)) nil)
          (message "Line copy appended"))
      (progn
        (kill-ring-save -p1 -p2)
        (if current-prefix-arg
            (message "Buffer text copied")
          (message "Text copied"))))
		;; TL: commented out the following two lines. Cursor remains at region.
    ;; (end-of-line)   
    ;; (forward-char)
    ))

;; toggle letter case
(global-set-key (kbd "C-9") 'xah-toggle-letter-case) 
(defun xah-toggle-letter-case ()
  "Toggle the letter case of current word or text selection.
Always cycle in this order: Init Caps, ALL CAPS, all lower.

URL `http://ergoemacs.org/emacs/modernization_upcase-word.html'
Version 2016-01-08"
  (interactive)
  (let (
        (deactivate-mark nil)
        -p1 -p2)
    (if (use-region-p)
        (setq -p1 (region-beginning)
              -p2 (region-end))
      (save-excursion
        (skip-chars-backward "[:alnum:]")
        (setq -p1 (point))
        (skip-chars-forward "[:alnum:]")
        (setq -p2 (point))))
    (when (not (eq last-command this-command))
      (put this-command 'state 0))
    (cond
     ((equal 0 (get this-command 'state))
      (upcase-initials-region -p1 -p2)
      (put this-command 'state 1))
     ((equal 1  (get this-command 'state))
      (upcase-region -p1 -p2)
      (put this-command 'state 2))
     ((equal 2 (get this-command 'state))
      (downcase-region -p1 -p2)
      (put this-command 'state 0)))))

;; kill buffer
(global-set-key (kbd "M-<f4>") 'kill-this-buffer)

;; revert buffer
(global-set-key (kbd "<f5>") 'revert-buffer)







(provide 'setup-buffer)