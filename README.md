gist-edit.el -- Emacs mode for editing files in a Gist repo
===========================================================

This is a mode for working on Github Gists in their full repo form.
It facilitates cloning, editing, committing, pushing, and listing them.

Install
-------

You can install with el-get or the following manual technique:

    $ cd ~/.emacs.d/vendor
    $ git clone git://github.com/rsanders/gist-edit.git

In your emacs config:

    (add-to-list 'load-path "~/.emacs.d/vendor/gist-edit")
    (require 'gist-edit)

Usage
-----

To use, run <kbd>M-x gist-edit</kbd> and provide it with a gist URL,
number, or private gist hash string.

Once in the edit mode, you can finish and push your edits with the
key sequence `C-x g f`.

Keymap
------

These keys are provided in the `C-x g` prefix map when you edit any
file in a gist-edit-checked-out repository:
    
    h - help
    b - browse the web page for the repo
    f - finish; commit and push to Github
    l - list all gists
    o - open another gist
    p - push locally committed changes
    s - magit-status
    

Functions
---------

* gist-edit - prompt for a gist id, then clone and edit that gist.
* 

Config
------

This package may be customized using the `M-x customize` feature of
Emacs.  Two variables are important to know:

* gist-edit/tmp-directory - the directory in which gists are checked
  out; defaults to `~/.emacs.d/gist-edit`

* gist-edit/prefix-key - the prefix key to use in the mode map; 
  defaults to `C-x g`

Requirements
------------

Emacs 24; may work under 23
Magit and Magithub packages installed for base functionality

Packages for extra functionality:

* browse-url - needed for `C-x g o` to work.
* gist by defunky - needed for `C-x g l` to work

Meta
----

* Code: `git clone git://github.com/rsanders/gist-edit.git`
* Home: <http://github.com/rsanders/gist-edit>
* Bugs: <http://github.com/rsanders/gist-edit/issues>


