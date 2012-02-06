;;;***
;;; gist-edit.el --- Edit a Github Gist file/repo
;;
;; Copyright (c) 2012 Robert Sanders
;;
;; Author: Robert Sanders <robert@curioussquid.com>
;; URL: http://github.com/rsanders/gist-edit
;; Version: 0.0.1
;; Keywords: convenience
;; Package-Requires: ((magit "1.1.1") (magithub "0.1"))

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:

;; Emacs Lisp

(require 'magit)
(require 'magithub)
(autoload 'browse-url-generic "browse-url")
(autoload 'gist               "gist")
(autoload 'gist               "gist-list")



;;; Customizations

;;;###autoload
(defgroup gist-edit nil
  "Customization for the 'gist-edit' package for editing GitHub gists (git-based pasties)"
  :prefix "gist-edit"
  )

(let ((loads (get 'gist-edit 'custom-loads))) (if (member '"gist-edit" loads) nil (put 'gist-edit 'custom-loads (cons '"gist-edit" loads))))

;;;###autoload
(defcustom gist-edit/tmp-directory
  "~/.emacs.d/gist-edit"
  ;; (let ((dir (format "%s%s/%d/" temporary-file-directory "gist-edit" (user-real-uid))))
  ;;   (unless (file-exists-p dir)
  ;;     (mkdir dir t))
  ;;   dir)
  "The directory in which to store checked out gists"
  :group 'gist-edit
  :type '(choice (const :tag "Default" "~/.emacs.d/gist-edit") directory)
  )

(defvar gist-edit/tmp-directory "~/.emacs.d/gist-edit" "\
The directory in which to store checked out gists")

;;;###autoload
(defcustom gist-edit/prefix-key
  (kbd "C-x g")
  "The prefix key for the Gist Edit keymap"
  :group 'gist-edit
  :type 'string
  )

(defvar gist-edit/prefix-key (kbd "C-x g") "\
The prefix key for the Gist Edit keymap")



;;; utility functions

(defun gist-edit/local-gist-dir (gistspec)
  (concat gist-edit/tmp-directory "/gist-"
          (gist-edit/gist-number-from-url gistspec)))

(defun gist-edit/gist-url (gistspec)
  (format "git://gist.github.com/%s.git"
          (gist-edit/gist-number-from-url gistspec)))

(defun gist-edit/writable-gist-url (gistspec)
  (format "git@gist.github.com:%s.git"
          (gist-edit/gist-number-from-url gistspec)))

(defun gist-edit/gist-number-from-url (url)
  (replace-regexp-in-string
   "\.git$" ""
   (first (last (split-string url "[/:]")))))

(defun gist-edit/gist-directory? (dir)
  "Given a path, returns true if the directory is a gist"
  (and
   (not (equal gist-edit/tmp-directory dir))
   (equal 0
          (string-match gist-edit/tmp-directory dir))))

(defun gist-edit/web-url ()
  "The URL for the Gist web page"
  (format "https://gist.github.com/%s" gist-edit-number))



;;; Repo creation

(defun gist-edit/setup-directory (number repo dir &optional variables)
  (with-temp-buffer
    (let ((alist
           `((nil . ((gist-edit-repo   . ,repo)
                     (gist-edit-number . ,number)
                     (gist-edit-buffer . t)
                     ,@variables
                     (eval . (gist-edit-mode t)))))))
      (print alist (current-buffer))
      (write-file (concat dir "/.dir-locals.el"))
      (append-to-file ".dir-locals.el\n" nil (concat dir "/.git/info/exclude"))
      )
    )
  )

(defun gist-edit/clone (repo destdir)
  "Clone an existing gist into a local directory"
  (let ((number (gist-edit/gist-number-from-url repo))
        (dir    (or destdir (gist-edit/local-gist-dir repo))))
    (make-directory (file-name-directory dir) t)
    (magit-run-git "clone" repo (expand-file-name dir))
    (gist-edit/setup-directory number repo dir)
    (gist-edit/open dir)))



;;; Interactive commands

;;;###autoload
(defun gist-edit (gistnum)
  "Edit an existing Github Gist by number/string name

  Will just open the local checkout if it already exists; otherwise
  clone the Gist and open it."
  (interactive "MGist Number: ")
  (let ((dir (gist-edit/local-gist-dir gistnum)))
    (unless (file-exists-p dir)
      (gist-edit/clone (gist-edit/gist-url gistnum) dir))
    (gist-edit/open dir)))

;;;###autoload
(defun gist-edit/open (dir)
  "Opens an already checked out gist for editing"
  (interactive "MGist Number: ")
  (find-file dir)
  (magit-status dir))

(defun gist-edit/browse-web-url ()
  "Open the URL for the Gist web page in the system browser"
  (interactive)
  (browse-url-generic (gist-edit/web-url)))

(defun gist-edit/finish ()
  "Save current file, commit all changes, and push"
  (interactive)
  (save-buffer)
  (unless (magit-everything-clean-p)
    (magit-stage-all)
    (magit-run-git "commit" "-m" "automatically updated gist"))
  (gist-edit/push))

(defun gist-edit/push ()
  "Push current repo to gist"
  (interactive)  
  (magit-run-git "push")
  (message "Gist updated!"))

(defun gist-edit/owned-by (gistspec)
  )

;;;###autoload
(defun gist-edit/list ()
  "Opens a list of open gists"
  (interactive)
  (find-file gist-edit/tmp-directory))



;;; Minor mode setup

(defvar gist-edit/keymap
  (let ((map (make-sparse-keymap)))
    ;;(define-key map (char-to-string help-char) 'gist-edit/help)
    ;;(define-key map [help] 'gist-edit/help)
    ;;(define-key map [f1] 'gist-edit/help)
    ;;(define-key map "h" 'gist-edit/help)
    (define-key map "b" 'gist-edit/browse-web-url)
    (define-key map "f" 'gist-edit/finish)
    (define-key map "l" 'gist-edit/list)
    (define-key map "m" 'gist-list)
    (define-key map "o" 'gist-edit)
    (define-key map "p" 'gist-edit/push)
    (define-key map "s" 'magit-status)
    map)
  "Keymap for Gist Edit mode.")

;;;###autoload
(define-minor-mode gist-edit-mode
  "Mode for editing a Gist"
  :lighter " GistE"
  :group 'gist-edit
  :require 'gist-edit
  :keymap `((,gist-edit/prefix-key . ,gist-edit/keymap))
  (if gist-edit-mode
      (progn
        ;; Don't start `smart-tab-mode' when in the minibuffer or a read-only
        ;; buffer.
        (when (or (minibufferp)
                  buffer-read-only
                  (member major-mode smart-tab-disabled-major-modes))
          (smart-tab-mode-off)))))


(provide 'gist-edit)

;;; Local Variables:
;;; lexical-binding: t
;;; End:
