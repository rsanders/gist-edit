;; -*- lexical-binding: t; -*-

(require 'magit)
(require 'magithub)

(defvar gist-edit/tmp-directory
  (let ((dir (format "%s%s/%d/" temporary-file-directory "gist-edit" (user-real-uid))))
    (unless (file-exists-p dir)
      (mkdir dir t))
    dir))

(defun gist-edit/local-gist-dir (gistspec)
  (concat gist-edit/tmp-directory
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

(defun gist-edit (gistnum)
  (interactive "MGist Number: ")
  (gist-edit/clone (gist-edit/gist-url gistnum))
  (gist-edit/open dir))

(setq repo "http://www.github.com/foo/bar.git")

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
  (dir-locals-set-directory-class dir 'gist-edit-directory)
  (find-file dir)
  (magit-status dir))

(defun gist-edit/clone (repo)
  ""
 ;; The trailing slash is necessary for Magit to be able to figure out
  ;; that this is actually a directory, not a file
  (let ((dir (concat gist-edit/tmp-directory 
                     (replace-regexp-in-string
                      "\.git$" ""
                      (first (last (split-string repo "[/:]"))))
                     )))
    (magit-run-git "clone" repo dir)
    ;; (gist-edit/_setup-project )
    (gist-edit/open dir)))

(dir-locals-set-class-variables 'gist-edit-directory
                                '((nil . ((gist-edit/is-gist . t)))))

(defvar gist-edit/subkeymap
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
