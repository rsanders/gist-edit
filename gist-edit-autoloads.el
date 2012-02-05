;;; gist-edit-autoloads.el --- automatically extracted autoloads
;;
;;; Code:


;;;### (autoloads (gist-edit-mode gist-edit/list gist-edit/open gist-edit
;;;;;;  gist-edit/prefix-key gist-edit/tmp-directory gist-edit) "gist-edit"
;;;;;;  "gist-edit.el" (20270 49074))
;;; Generated autoloads from gist-edit.el

(let ((loads (get 'gist-edit 'custom-loads))) (if (member '"gist-edit" loads) nil (put 'gist-edit 'custom-loads (cons '"gist-edit" loads))))

(defvar gist-edit/tmp-directory "~/.emacs.d/gist-edit" "\
The directory in which to store checked out gists")

(custom-autoload 'gist-edit/tmp-directory "gist-edit" t)

(defvar gist-edit/prefix-key (kbd "C-x g") "\
The prefix key for the Gist Edit keymap")

(custom-autoload 'gist-edit/prefix-key "gist-edit" t)

(autoload 'gist-edit "gist-edit" "\
Edit an existing Github Gist by number/string name

  Will just open the local checkout if it already exists; otherwise
  clone the Gist and open it.

\(fn GISTNUM)" t nil)

(autoload 'gist-edit/open "gist-edit" "\
Opens an already checked out gist for editing

\(fn DIR)" t nil)

(autoload 'gist-edit/list "gist-edit" "\
Opens a list of open gists

\(fn)" t nil)

(autoload 'gist-edit-mode "gist-edit" "\
Mode for editing a Gist

\(fn &optional ARG)" t nil)

;;;***

;;;### (autoloads nil nil ("gist-edit-pkg.el") (20270 49081 351830))

;;;***

(provide 'gist-edit-autoloads)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; gist-edit-autoloads.el ends here
