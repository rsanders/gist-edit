;; -*- lexical-binding: t; -*-

;; (require 'magit)
;; (require 'magithub)

(defgroup gist-edit nil
  "Customization for the 'gist-edit' package for editing GitHub gists (git-based pasties)"
  :prefix "gist-edit"
  )

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

(defun gist-edit/local-gist-dir (gistspec)
  (concat gist-edit/tmp-directory "/gist-"
          (gist-edit/gist-number-from-url gistspec)))

(defun gist-edit/gist-url (gistspec)
  (format "https://gist.github.com/%s.git"
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

(defun gist-edit/list ()
  "Opens a list of open gists"
  (interactive)
  (find-file gist-edit/tmp-directory))

(defun gist-edit/open (dir)
  "Opens an already checked out gist for editing"
 (find-file dir)
  (magit-status dir))

(defun gist-edit/setup-directory (number repo dir &optional variables)
  (with-temp-buffer
    (let ((alist
           `((nil . ((gist-edit-repo . ,repo)
                     (gist-edit-number . ,number)
                     (gist-edit-buffer . t)
                     ,@variables
                     (eval . (gist-edit-mode t)))))))
      (write-file (concat dir "/.dir-locals.el"))
      )
    )
  )


(defun gist-edit (gistnum)
  (interactive "MGist Number: ")
  (let ((dir (gist-edit/local-gist-dir gistnum)))
    (unless (file-exists-p dir)
      (gist-edit/clone (gist-edit/gist-url gistnum) dir))
    (gist-edit/open dir)))


(defun gist-edit/clone (repo destdir)
  "Clone an existing gist into a local directory"
  (let ((number (gist-edit/gist-number-from-url repo))
        (dir    (or destdir (gist-edit/local-gist-dir repo))))
    (make-directory (file-name-directory dir) t)
    (magit-run-git "clone" repo dir)
    (gist-edit/setup-directory number repo dir)
    (gist-edit/open dir)))

(defvar gist-edit/keymap
  (let ((map (make-sparse-keymap)))
    (define-key map (char-to-string help-char) 'gist-edit/help)
    (define-key map [help] 'gist-edit/help)
    (define-key map [f1] 'gist-edit/help)
    (define-key map "p" 'gist-edit/push)
    (define-key map "f" 'gist-edit/finish)
    map)
  "Keymap for Gist Edit mode.")

(define-minor-mode gist-edit-mode
  "Enable `smart-tab' to be used in place of tab.

With no argument, this command toggles the mode.
Non-null prefix argument turns on the mode.
Null prefix argument turns off the mode."
  :lighter " GistE"
  :group 'gist-edit
  :require 'gist-edit
  :keymap gist-edit/keymap
  (if smart-tab-mode
      (progn
        ;; Don't start `smart-tab-mode' when in the minibuffer or a read-only
        ;; buffer.
        (when (or (minibufferp)
                  buffer-read-only
                  (member major-mode smart-tab-disabled-major-modes))
          (smart-tab-mode-off)))))


;; (makunbound 'gist-edit/tmp-directory)

(provide 'gist-edit)
