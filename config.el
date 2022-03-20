;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name    "Jay L. Colbert"
      user-mail-address "jaylcolbert@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Overpass" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;(setq doom-theme 'doom-one)
;;(setq doom-theme 'doom-earl-grey)
;;(setq doom-theme 'doom-flatwhite)
;;(setq doom-theme 'doom-nord)
;;(setq doom-theme 'doom-opera)
;;(setq doom-theme 'doom-opera-light)
;;(setq doom-theme 'doom-wilmersdorf)
(setq doom-theme 'doom-zenburn)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory       "~/Documents/org/"
      org-roam-directory  (file-truename "~/Documents/org/digital-garden/org"))


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(display-time-mode 1)
(display-battery-mode 1)
(add-to-list 'completion-ignored-extensions ".DS_Store")

(setq initial-frame-alist
      '((top . 0.5) (left . 0.5) (width . 80) (height . 40)))

(setq doom-fallback-buffer-name "► Doom"
      +doom-dashboard-name "► Doom"
      frame-title-format
      '(""
        (:eval
         (if (s-contains-p org-roam-directory (or buffer-file-name ""))
             (replace-regexp-in-string
              ".*/[0-9]*-?" "☰ "
              (subst-char-in-string ?_ ?  buffer-file-name))
           "%b"))
        (:eval
         (let ((project-name (projectile-project-name)))
           (unless (string= "-" project-name)
             (format (if (buffer-modified-p)  " ◉ %s" "  ●  %s") project-name)))))
      which-key-idle-delay 0.5)

(after! citar
  ;; use consult-completing-read for enhanced interface
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)
  (setq! citar-bibliography   '("~/Documents/org/digital-garden/org/biblio.bib")
         citar-library-paths  '("~/Documents/Zotero"))
  (setq citar-symbols
        `((file ,(all-the-icons-faicon "file-o" :face 'all-the-icons-green :v-adjust -0.1) . " ")
          (note ,(all-the-icons-material "speaker_notes" :face 'all-the-icons-blue :v-adjust -0.3) . " ")
          (link ,(all-the-icons-octicon "link" :face 'all-the-icons-orange :v-adjust 0.01) . " "))
        citar-symbol-separator "  "))

(after! company
  (setq company-idle-delay 0.5))

(use-package! doct
  :commands doct)

(after! doom-modeline
  (doom-modeline-def-segment buffer-name
    "Display the current buffer's name, without any other information."
    (concat
     (doom-modeline-spc)
     (doom-modeline--buffer-name)))

  (doom-modeline-def-segment pdf-icon
    "PDF icon from all-the-icons."
    (concat
     (doom-modeline-spc)
     (doom-modeline-icon 'octicon "file-pdf" nil nil
                         :face (if (doom-modeline--active)
                                   'all-the-icons-red
                                 'mode-line-inactive)
                         :v-adjust 0.02)))

  (defun doom-modeline-update-pdf-pages ()
    "Update PDF pages."
    (setq doom-modeline--pdf-pages
          (let ((current-page-str (number-to-string (eval `(pdf-view-current-page))))
                (total-page-str (number-to-string (pdf-cache-number-of-pages))))
            (concat
             (propertize
              (concat (make-string (- (length total-page-str) (length current-page-str)) ? )
                      " P" current-page-str)
              'face 'mode-line)
             (propertize (concat "/" total-page-str) 'face 'doom-modeline-buffer-minor-mode)))))

  (doom-modeline-def-segment pdf-pages
    "Display PDF pages."
    (if (doom-modeline--active) doom-modeline--pdf-pages
      (propertize doom-modeline--pdf-pages 'face 'mode-line-inactive)))

  (doom-modeline-def-modeline 'pdf
    '(bar window-number pdf-pages pdf-icon buffer-name)
    '(misc-info matches major-mode process vcs)))

(after! evil
  (setq evil-vsplit-window-right t
        evil-split-window-below t
        evil-move-cursor-back t
        evil-kill-on-visual-paste nil)
  (defadvice! prompt-for-buffer (&rest _)
    :after '(evil-window-split evil-window-vsplit)
    (consult-buffer))
  (map! :map evil-window-map
        "SPC" #'rotate-layout
        ;; Navigation
        "<left>"     #'evil-window-left
        "<down>"     #'evil-window-down
        "<up>"       #'evil-window-up
        "<right>"    #'evil-window-right
        ;; Swapping windows
        "C-<left>"       #'+evil/window-move-left
        "C-<down>"       #'+evil/window-move-down
        "C-<up>"         #'+evil/window-move-up
        "C-<right>"      #'+evil/window-move-right))

(use-package! hydra-posframe
  :hook (after-init . hydra-posframe-mode)
  :config
  (setq hydra-posframe-parameters '((alpha 100 100)
                                    (left-fringe . 10)
                                    (right-fringe . 10))
        hydra-posframe-poshandler 'jc-frame-bottom-poshandler))

(use-package! info-colors
  :commands info-colors-fontify-node
  :init
  (add-hook 'Info-selection-hook #'info-colors-fontify-node))

(use-package major-mode-hydra
  :bind
  ("C-SPC" . major-mode-hydra)
  :config
  (setq major-mode-hydra-invisible-quit-key "q"
        major-mode-hydra-title-generator #'jc-major-mode-hydra-title-generator))

(major-mode-hydra-define emacs-lisp-mode nil
  ("Eval"
   (("b" eval-buffer "buffer")
    ("d" eval-defun "defun")
    ("e" eval-last-sexp "sexp")
    ("r" eval-region "region"))
   "REPL"
   (("I" ielm "ielm"))
   "Test"
   (("t" ert "prompt")
    ("T" (ert t) "all")
    ("F" (ert :failed) "failed"))
   "Doc"
   (("d" describe-foo-at-point "thing-at-pt")
    ("f" describe-function "function")
    ("v" describe-variable "variable")
    ("i" info-lookup-symbol "info lookup"))))

(use-package mixed-pitch
  :hook
  ;; If you want it in all text modes:
  (text-mode . mixed-pitch-mode)
  :config
  (setq mixed-pitch-set-height t))

(after! org
  (setq org-hide-emphasis-markers t
        org-ellipsis " ▾ ")
  (after! org-capture
    (advice-add 'org-capture-select-template :override #'org-capture-select-template-prettier)
    (advice-add 'org-mks :override #'org-mks-pretty)
    (setq doct-after-conversion-functions '(+doct-iconify-capture-templates))
    (defun set-org-capture-templates ()
      (setq org-capture-templates
            (doct `(("Slipbox" :keys "s"
                     :icon ("inbox" :set "octicon" :color "green")
                     :file "digital-garden/org/inbox.org"
                     :type entry
                     :template ("* %?\n"))
                    ("Personal todo" :keys "t"
                     :icon ("checklist" :set "octicon" :color "green")
                     :file +org-capture-todo-file
                     :prepend t
                     :headline "Inbox"
                     :type entry
                     :template ("* TODO %?"
                                "%i %a"))
                    ("Personal note" :keys "n"
                     :icon ("sticky-note-o" :set "faicon" :color "green")
                     :file +org-capture-todo-file
                     :prepend t
                     :headline "Inbox"
                     :type entry
                     :template ("* %?"
                                "%i %a"))
                    ("Email" :keys "e"
                     :icon ("envelope" :set "faicon" :color "blue")
                     :file +org-capture-todo-file
                     :prepend t
                     :headline "Inbox"
                     :type entry
                     :template ("* TODO %^{type|reply to|contact} %\\3 %? :email:"
                                "Send an email %^{urgency|soon|ASAP|anon|at some point|eventually} to %^{recipient}"
                                "about %^{topic}"
                                "%U %i %a"))
                    ("Interesting" :keys "i"
                     :icon ("eye" :set "faicon" :color "lcyan")
                     :file +org-capture-todo-file
                     :prepend t
                     :headline "Interesting"
                     :type entry
                     :template ("* [ ] %{desc}%? :%{i-type}:"
                                "%i %a")
                     :children (("Webpage" :keys "w"
                                 :icon ("globe" :set "faicon" :color "green")
                                 :desc "%(org-cliplink-capture) "
                                 :i-type "read:web")
                                ("Article" :keys "a"
                                 :icon ("file-text" :set "octicon" :color "yellow")
                                 :desc ""
                                 :i-type "read:reaserch")
                                ("Information" :keys "i"
                                 :icon ("info-circle" :set "faicon" :color "blue")
                                 :desc ""
                                 :i-type "read:info")
                                ("Idea" :keys "I"
                                 :icon ("bubble_chart" :set "material" :color "silver")
                                 :desc ""
                                 :i-type "idea")))
                    ("Tasks" :keys "k"
                     :icon ("inbox" :set "octicon" :color "yellow")
                     :file +org-capture-todo-file
                     :prepend t
                     :headline "Tasks"
                     :type entry
                     :template ("* TODO %? %^G%{extra}"
                                "%i %a")
                     :children (("General Task" :keys "k"
                                 :icon ("inbox" :set "octicon" :color "yellow")
                                 :extra "")
                                ("Task with deadline" :keys "d"
                                 :icon ("timer" :set "material" :color "orange" :v-adjust -0.1)
                                 :extra "\nDEADLINE: %^{Deadline:}t")
                                ("Scheduled Task" :keys "s"
                                 :icon ("calendar" :set "octicon" :color "orange")
                                 :extra "\nSCHEDULED: %^{Start time:}t")))
                    ("Project" :keys "p"
                     :icon ("repo" :set "octicon" :color "silver")
                     :prepend t
                     :type entry
                     :headline "Inbox"
                     :template ("* %{time-or-todo} %?"
                                "%i"
                                "%a")
                     :file ""
                     :custom (:time-or-todo "")
                     :children (("Project-local todo" :keys "t"
                                 :icon ("checklist" :set "octicon" :color "green")
                                 :time-or-todo "TODO"
                                 :file +org-capture-project-todo-file)
                                ("Project-local note" :keys "n"
                                 :icon ("sticky-note" :set "faicon" :color "yellow")
                                 :time-or-todo "%U"
                                 :file +org-capture-project-notes-file)
                                ("Project-local changelog" :keys "c"
                                 :icon ("list" :set "faicon" :color "blue")
                                 :time-or-todo "%U"
                                 :heading "Unreleased"
                                 :file +org-capture-project-changelog-file)))
                    ("\tCentralised project templates"
                     :keys "o"
                     :type entry
                     :prepend t
                     :template ("* %{time-or-todo} %?"
                                "%i"
                                "%a")
                     :children (("Project todo"
                                 :keys "t"
                                 :prepend nil
                                 :time-or-todo "TODO"
                                 :heading "Tasks"
                                 :file +org-capture-central-project-todo-file)
                                ("Project note"
                                 :keys "n"
                                 :time-or-todo "%U"
                                 :heading "Notes"
                                 :file +org-capture-central-project-notes-file)
                                ("Project changelog"
                                 :keys "c"
                                 :time-or-todo "%U"
                                 :heading "Unreleased"
                                 :file +org-capture-central-project-changelog-file)))))))
    (set-org-capture-templates)
    (unless (display-graphic-p)
      (add-hook 'server-after-make-frame-hook
                (defun org-capture-reinitialise-hook ()
                  (when (display-graphic-p)
                    (set-org-capture-templates)
                    (remove-hook 'server-after-make-frame-hook
                                 #'org-capture-reinitialise-hook))))))
  (setq org-journal-dir "~/Documents/org/journal/"
        org-journal-date-prefix "* "
        org-journal-time-prefix "** "
        org-journal-date-format "%B %d, %Y (%A) "
        org-journal-file-format "%Y-%m-%d.org")
  (after! org-roam
    (use-package! consult-org-roam
      :demand t
      :bind
      (("C-c n e" . consult-org-roam-file-find)
       ("C-c n b" . consult-org-roam-backlinks)
       ("C-c n r" . consult-org-roam-search)))
    (add-hook 'org-roam-capture-new-node-hook #'jc/tag-new-node-as-draft)
    (cl-defmethod org-roam-node-type ((node org-roam-node))
      "Return the TYPE of NODE."
      (condition-case nil
          (file-name-nondirectory
           (directory-file-name
            (file-name-directory
             (file-relative-name (org-roam-node-file node) org-roam-directory))))
        (error "")))
    (setq
     org-roam-capture-templates
     '(("m" "main" plain
        "%?"
        :if-new (file+head "main/${slug}.org"
                           "#+title: ${title}\n")
        :immediate-finish t
        :unnarrowed t)
       ("r" "reference" plain "%?"
        :if-new
        (file+head "reference/${slug}.org" "#+title: ${title}\n")
        :immediate-finish t
        :unnarrowed t)
       ("a" "article" plain "%?"
        :if-new
        (file+head "articles/${slug}.org" "#+title: ${title}\n#+filetags: :article:\n")
        :immediate-finish t
        :unnarrowed t))
     org-roam-node-display-template
     (concat "${type:15} ${title:*} " (propertize "${tags:10}" 'face 'org-tag)))))

(use-package! org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t
        org-appear-autosubmarkers t
        org-appear-autolinks nil)
  ;; for proper first-time setup, `org-appear--set-elements'
  ;; needs to be run after other hooks have acted.
  (run-at-time nil nil #'org-appear--set-elements))

(use-package! org-ol-tree
  :commands org-ol-tree
  :init
  (map! :map org-mode-map
        :after org
        :localleader
        :desc "Outline" "O" #'org-ol-tree))

(use-package! org-roam-desktop
  :after org
  :init
  (map! "C-c n d" #'org-roam-desktop
        "C-c n a" #'org-roam-desktop-node-add)
  :config
  (setq org-roam-desktop-basename   "*OR-Desk--"
        org-roam-desktop-directory  "~/Documents/org/digital-garden/org"))

(use-package! org-transclusion
  :commands org-transclusion-mode
  :init
  (map! :after org :map org-mode-map
        "<f12>" #'org-transclusion-mode))

(use-package! zetteldesk
  :after org-roam
  :config
  (setq zetteldesk-hydra-prefix (kbd "C-c z"))
  (zetteldesk-mode)
  (require 'zetteldesk-kb))
