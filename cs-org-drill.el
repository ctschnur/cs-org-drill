;;; cs-org-drill.el --- my org drill configuration -*- lexical-binding: t; -*-

;; Copyright (C) 2020  chris

;; Author: chris <chris@chris-lenovo>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(add-to-list 'load-path (expand-file-name "~/.emacs.d/elisp/org-drill-related-files/"))

(require 'org-drill)
(require 'org)
(require 'hydra)


(defun org-cycle-hide-drawers (state)
  "Re-hide all drawers after a visibility state change."
  (when (and (derived-mode-p 'org-mode)
             (not (memq state '(overview folded contents))))
    (save-excursion
      (let* ((globalp (memq state '(contents all)))
             (beg (if globalp
                    (point-min)
                    (point)))
             (end (if globalp
                    (point-max)
                    (if (eq state 'children)
                      (save-excursion
                        (outline-next-heading)
                        (point))
                      (org-end-of-subtree t)))))
        (goto-char beg)
        (while (re-search-forward org-drawer-regexp end t)
          (save-excursion
            (beginning-of-line 1)
            (when (looking-at org-drawer-regexp)
              (let* ((start (1- (match-beginning 0)))
                     (limit
                       (save-excursion
                         (outline-next-heading)
                           (point)))
                     (msg (format
                            (concat
                              "org-cycle-hide-drawers:  "
                              "`:END:`"
                              " line missing at position %s")
                            (1+ start))))
                (if (re-search-forward "^[ \t]*:END:" limit t)
                  (outline-flag-region start (point-at-eol) t)
                  (user-error msg))))))))))

(defun my-new-org-drill-flashcard ()
  (interactive)
  (progn
    (org-insert-heading-respect-content)
    (save-excursion
      (insert " :drill:")
      (insert "\n-")
      (org-insert-subheading t)
      ;; (org-insert-heading-respect-content)
      ;; (org-metaright)
      (insert "Answer\n"))))

(defun klin-run-org-drill-hydra ()
  (interactive)
  (let* ((hydra-body (eval (remove nil
                                   `(defhydra hydra-klin-org-drill
                                      (:columns 1 :exit t)
                                      "org-drill"
                                      ("d"
                                       (lambda ()
                                         (interactive)
                                         (org-drill))
                                       "drill")
                                      ("D"
                                       (lambda ()
                                         (interactive)
                                         (org-drill-entry))
                                       "drill item at point")
                                      ("n"
                                       (lambda ()
                                         (interactive)
                                         (my-new-org-drill-flashcard))
                                       "new flashcard")
                                      ("c"
                                       (lambda ()
                                         (interactive)
                                         (org-drill-cram))
                                       "cram")
                                      ("r"
                                       (lambda ()
                                         (interactive)
                                         (org-cycle-hide-drawers 'all)
                                         (call-interactively 'org-drill-resume))
                                       "resume")
                                      ("h"
                                       (lambda ()
                                         (interactive)
                                         (org-cycle-hide-drawers 'all))
                                       "hide drawers")
                                      ("s"
                                       (lambda ()
                                         (interactive)
                                         (org-show-all))
                                       "show drawers")
                                      ("t"
                                       (lambda ()
                                         (interactive)
                                         (org-toggle-tag "drill"))
                                       "toggle drill tag")
                                      ("q" nil "cancel"))))))
    (hydra-klin-org-drill/body)
    (fmakunbound 'hydra-klin-org-drill/body)
    (setq hydra-klin-org-drill/body nil)))

(define-key org-mode-map (kbd "C-M-, d") 'klin-run-org-drill-hydra)

(provide 'cs-org-drill)
;;; cs-org-drill.el ends here
