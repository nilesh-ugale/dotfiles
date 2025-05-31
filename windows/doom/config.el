;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;(setq doom-theme 'doom-one)
(load-theme 'catppuccin :no-confirm)
(setq catppuccin-flavor 'frappe) ;; or 'latte, 'macchiato, or 'mocha or 'frappe
(catppuccin-reload)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "//wsl.localhost/Ubuntu-24.04/home/nilesh/org/")


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

(after! org-roam
  (setq org-roam-graph-executable "C:/Program Files/Graphviz/bin/dot.exe")
  (setq org-roam-directory "//wsl.localhost/Ubuntu-24.04/home/nilesh/org/roam/")
)


(after! org
  (require 'org-roam)
  (require 'org-habit)
  (require 'org-id)

  (setq org-id-link-to-org-use-id t)
  (setq org-log-into-drawer "LOGBOOK")
  (setq org-todo-keywords
    '(
      (sequence "TODO(t!)" "REVIEW(v!)" "REPEAT(r!)" "GOAL" "DELEGATED(d!)" "NEXT(n!)" "ACTIVE(a!)" "WAITING(w@)" "MEET(m!)" "HOLD(h@)" "SOMEDAY" "|" "DONE(x@)" "ACHIEVED(a@)" "CANCELLED(c@)")
      (sequence "HABIT(h!)" "|" "DONE(x@)")
    )
  )
  (setq org-todo-keyword-faces
    '(
      ("TODO" . (:foreground "OrangeRed" :weight bold :slant italic))
      ("REPEAT" . (:foreground "OrangeRed" :weight bold :slant italic))
      ("REVIEW". (:foreground "OrangeRed" :weight bold :slant italic))

      ("MEET" . (:foreground "Gold" :weight bold :slant italic))

      ("DELEGATED" . (:foreground "DarkOrange" :weight bold :slant italic))
      ("WAITING" . (:foreground "Yellow" :weight bold :slant italic))

      ("NEXT" . (:foreground "DeepSkyBlue" :weight bold :slant italic))
      ("HABIT" . (:foreground "DeepSkyBlue" :weight bold :slant italic))
      ("ACTIVE" . (:foreground "LawnGreen" :weight bold :slant italic))

      ("GOAL" . (:foreground "OrangeRed" :weight bold :slant italic))

      ("HOLD" . (:foreground "Magenta" :weight bold :slant italic))
      ("SOMEDAY" . (:foreground "Magenta" :weight bold :slant italic))

      ("DONE" . (:foreground "LightGreen" :weight bold :slant italic))
      ("ACHIEVED" . (:foreground "LightGreen" :weight bold :slant italic))
      ("CANCELLED" . (:foreground "LightGreen" :weight bold :slant italic))
    )
  )
  (setq org-tags-column -100)
  (setq org-log-done 'note)
  (setq org-log-repeat 'lognoterepeat)
  (setq org-todo-repeat-to-state "REPEAT")
  (setq org-agenda-skip-scheduled-if-done t)
  (setq org-agenda-skip-scheduled-if-deadline-is-shown t) ;; Prevent duplicate entries in agenda
  (setq org-agenda-skip-deadline-if-done t)     ;; Skip DONE items with deadlines
  (setq org-agenda-skip-timestamp-if-done t)    ;; Skip DONE items with any timestamp
  (setq org-agenda-skip-timestamp-if-deadline t) ;; Skip items with deadline timestamp when already shown elsewhere

  (setq org-habit-graph-column 60)
  (setq org-habit-preceding-days 7)
  (setq org-habit-following-days 7)
  (setq org-log-reschedule 'logreschedule)
  (setq org-log-redeadline 'logredeadline)

  ;; Or make it buffer-local inside a hook
  (setq org-capture-templates
    '(
      (
        "t" "Task"
        entry (file "//wsl.localhost/Ubuntu-24.04/home/nilesh/org/inbox.org")
        "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:"
      )
      (
        "j" "Journal"
        entry (file+datetree "//wsl.localhost/Ubuntu-24.04/home/nilesh/org/journal.org")
        "* %?"
      )
      (
        "m" "Minutes of Meet (auto timestamp)"
        entry (file+datetree+prompt "//wsl.localhost/Ubuntu-24.04/home/nilesh/org/meetings.org")
        "* %? :meeting:\n:PROPERTIES:\n:CREATED: %U\n:END:\n** Notes\n** Action Items\n*** TODO "
      )
      (
        "M" "Minutes of Meet (prompt for timestamp)"
        entry (file+datetree+prompt "//wsl.localhost/Ubuntu-24.04/home/nilesh/org/meetings.org")
        "* %? :meeting:\n:PROPERTIES:\n:CREATED: %^U\n:END:\n** Notes\n** Action Items\n*** TODO "
      )
      (
        "g" "Goal"
      )
      (
        "gl" "Long Term Goal (2+ years)"
        entry (file+headline "//wsl.localhost/Ubuntu-24.04/home/nilesh/org/goals.org" "Long Term Goals")
        "** GOAL %^{Goal}\nRecorded on %U - Last reviewed on %U\n:SMART:\n:SPECIFICS: %^{Specifics}\n:MEASURABLE: %^{Measurable}\n:ACHIEVABLE: %^{Achievable}\n:RELEVANT: %^{Relevant}\n:TIMEBOUND: %^{Time Bound}\n:END:\n:ACTIONS:\n:END:"
      )
      (
        "gm" "Medium Term Goal (6 months - 2 years)"
        entry (file+headline "//wsl.localhost/Ubuntu-24.04/home/nilesh/org/goals.org" "Medium Term Goals")
        "** GOAL %^{Goal}\nRecorded on %U - Last reviewed on %U\n:SMART:\n:SPECIFICS: %^{Specifics}\n:MEASURABLE: %^{Measurable}\n:ACHIEVABLE: %^{Achievable}\n:RELEVANT: %^{Relevant}\n:TIMEBOUND: %^{Time Bound}\n:END:\n:ACTIONS:\n:END:"
      )
      (
        "gs" "Short Term Goal (next 6 months)"
        entry (file+headline "//wsl.localhost/Ubuntu-24.04/home/nilesh/org/goals.org" "Short Term Goals")
        "** GOAL %^{Goal}\nRecorded on %U - Last reviewed on %U\n:SMART:\n:SPECIFICS: %^{Specifics}\n:MEASURABLE: %^{Measurable}\n:ACHIEVABLE: %^{Achievable}\n:RELEVANT: %^{Relevant}\n:TIMEBOUND: %^{Time Bound}\n:END:\n:ACTIONS:\n:END:"
      )
    )
  )
  (setq org-agenda-custom-commands
    '(
      ;; Delegated Agenda View
      (
        "D" "Delegated"
        (
          (tags-todo "work+PRIORITY=\"A\"+TODO=\"DELEGATED\""
            (
              (org-agenda-overriding-header "🔥 High priority")
              (org-agenda-todo-ignore-deadlines 'far)
            )
          )
          (tags-todo "work+TODO=\"DELEGATED\""
            (
              (org-agenda-overriding-header "All Tasks")
            )
          )
        )
      )
      ;; Personal View
      (
        "p" "Personal"
        (
          (agenda ""
            (
              (org-agenda-overriding-header "📆 Today")
              (org-agenda-span 'day)
              (org-agenda-start-day "0d")
            )
          )
          (tags-todo
            "personal"
            (
              (org-agenda-overriding-header "All Tasks")
              (org-agenda-todo-ignore-deadlines 'far)
            )
          )
        )
      )
      ;; New Tag Agenda View
      (
        "n" "New"
        (
          (tags-todo "new"
            ((org-agenda-overriding-header "All Tasks"))
          )
        )
      )
      ;; Goals
      (
        "g" "🎯 Goals Dashboard"
        (
        ;; Short-term goals
          (tags-todo "goal+shortterm+TODO=\"GOAL\""
            (
              (org-agenda-overriding-header "🔵 Short Term Goals (Next 6 months)")
              (org-tags-match-list-sublevels t)
            )
          )
          ;; Medium-term goals
          (tags-todo "goal+mediumterm+TODO=\"GOAL\""
            (
              (org-agenda-overriding-header "🟠 Medium Term Goals (6 months - 2 years)")
              (org-tags-match-list-sublevels t)
            )
          )
          ;; Long-term goals
          (tags-todo "goal+longterm+TODO=\"GOAL\""
            (
              (org-agenda-overriding-header "🔴 Long Term Goals (2+ years)")
              (org-tags-match-list-sublevels t)
            )
          )
          ;; Deadline overview for goals
          (agenda ""
              (
                (org-agenda-span 'week)
                (org-agenda-start-on-weekday 1)
                (org-agenda-overriding-header "📅 Deadlines for Goal Tasks")
                (org-agenda-prefix-format "  %-12t %b")
                (org-agenda-skip-function '(org-agenda-skip-entry-if 'nottodo '("TODO")))
                (org-agenda-tag-filter-preset '("+goal")
              )
            )
          )
          ;; Action items under goals
          (tags-todo "goal+TODO=\"TODO\""
            (
              (org-agenda-overriding-header "📝 Goal Action Items")
              (org-agenda-sorting-strategy '(priority-down))
            )
          )
        )
      )
      ;; Dashboard
      (
        "d" "📊 Dashboard"
        (
          ;; High-priority tasks
          (tags-todo "+PRIORITY=\"A\""
            (
              (org-agenda-overriding-header "🔥 High Priority Tasks")
              (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled 'deadline))
              (org-agenda-prefix-format "  %?-12t% s")
            )
          )
          ;; Today's Agenda
          (agenda ""
            (
              (org-agenda-span 'day)
              (org-agenda-start-day "0d")
              (org-agenda-overriding-header "📆 Today")
              (org-agenda-show-all-dates t)
              (org-agenda-sorting-strategy '(time-up priority-down))
              (org-deadline-warning-days 3)
              (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo '("DONE" "CANCELLED" "ACHIEVED" "HABIT")))
            )
          )
          ;; Waiting tasks
          (tags-todo "TODO=\"WAITING\""
            (
              (org-agenda-overriding-header "⏳ Waiting On")
              (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled))
              (org-agenda-prefix-format "  %?-12t% s")
            )
          )
          ;; All Tasks
          (tags-todo "-personal-TODO=\"DELEGATED\""
            (
              (org-agenda-overriding-header "Tasks")
              (org-agenda-todo-ignore-scheduled 'all)
              (org-agenda-skip-function
                (lambda ()
                  (or
                    (org-agenda-skip-entry-if 'timestamp)
                    (org-agenda-skip-entry-if 'todo '("WAITING" "REPEAT" "HOLD"))
                  )
                )
              )
            )
          )
          ;; Upcoming Week
          (agenda ""
            (
              (org-agenda-span 'week)
              (org-agenda-start-on-weekday 1)
              (org-agenda-start-day "+1d")
              (org-agenda-overriding-header "📅 Week Overview")
              (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo '("DONE" "CANCELLED" "ACHIEVED" "HABIT")))
            )
          )
        )
      )
      ;; Habits
      (
        "h" "Habits"
        (
          (agenda ""
            (
              (org-agenda-span 7)
              (org-agenda-show-log t)
              (org-habit-show-habits-only t)
              (org-agenda-skip-function
                '(org-agenda-skip-entry-if 'notregexp "\\* HABIT")
              )
            )
          )
        )
      )
    )
  )
)
(custom-set-faces!
  '(default :background nil)
)
(menu-bar-mode 1)
(setq confirm-kill-emacs nil)
(add-to-list 'default-frame-alist
  '(font . "MesloLGSDZ Nerd Font-12:slant=italic:weight=semibold")
)

;; start org agenda at startup
(defun emacs-startup-screen ()
  "Display the weekly org-agenda and all todos."
  (org-agenda nil "d"))
(add-hook 'emacs-startup-hook #'emacs-startup-screen)

;; auto-fill-mode is automatic line break
(remove-hook! 'text-mode-hook #'auto-fill-mode)
 ;; Can be enabled when you want with SPC-t-w
(remove-hook! 'text-mode-hook #'visual-line-mode)

(add-hook 'org-mode-hook
  (lambda ()
    (when
      (and buffer-file-name
          (string-match "meetings.org$" buffer-file-name)
      )
    (setq-local org-use-tag-inheritance nil)
    )
  )
)

(setq display-line-numbers-type 'relative)

(use-package! websocket
    :after org-roam)

(use-package! org-roam-ui
    :after org-roam ;; or :after org
;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
;;         a hookable mode anymore, you're advised to pick something yourself
;;         if you don't care about startup time, use
;;  :hook (after-init . org-roam-ui-mode)
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))

(let ((tex-path "C:/texlive/2025/bin/windows")) ;; or MiKTeX path
  (setenv "PATH" (concat tex-path ";" (getenv "PATH")))
  (add-to-list 'exec-path tex-path))