;;; vscode-icon.el --- Utility package to provide Vscode style icons -*- lexical-binding: t -*-

;; Copyright (C) 2018 James Nguyen

;; Author: James Nguyen <james@jojojames.com>
;; Maintainer: James Nguyen <james@jojojames.com>
;; URL: https://github.com/jojojames/vscode-icon-emacs
;; Version: 0.0.1
;; Package-Requires: ((emacs "25.1"))
;; Keywords: files, tools
;; HomePage: https://github.com/jojojames/vscode-icon-emacs

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; This package provides a utility function that returns vscode style icons.
;; The entry point is `vscode-icon-for-file'.

;;; Code:
(require 'image)
(eval-when-compile (require 'subr-x)) ; `if-let*' and `when-let*'

;; Compatibility

(eval-and-compile
  (with-no-warnings
    (if (version< emacs-version "26")
        (progn
          (defalias 'vscode-icon-if-let* #'if-let)
          (defalias 'vscode-icon-when-let* #'when-let)
          (function-put #'vscode-icon-if-let* 'lisp-indent-function 2)
          (function-put #'vscode-icon-when-let* 'lisp-indent-function 1))
      (defalias 'vscode-icon-if-let* #'if-let*)
      (defalias 'vscode-icon-when-let* #'when-let*))))

;; Customizations

(defcustom vscode-icon-size 23
  "The size of the icon when creating an icon.

A number other than 23 is only available if there are icons of that size.

See `vscode-icon-extra-icon-directory'."
  :type 'number
  :group 'vscode-icon)

(defcustom vscode-icon-extra-icon-directory "~/.emacs.d/icons/"
  "Directory to install vscode icons in.

This directory is searched when icons are being searched for in addition to
`vscode-icon-dir'."
  :type 'string
  :group 'vscode-icon)

;; Private variables

(defvar vscode-icon-root (file-name-directory load-file-name)
  "Store the directory dired-sidebar.el was loaded from.")

(defvar vscode-icon-dir (format "%sicons/" vscode-icon-root)
  "Store the icons directory of `vscode-icon'.")

(defvar vscode-icon-source-dir (format "%ssource/" vscode-icon-root)
  "Store the source directory of `vscode-icon' containing the svg images.")

(defvar vscode-icon-dir-alist
  '(("scripts" . "script")
    ("build" . "binary")
    ("node_modules" . "npm")
    ("tests" . "test")
    ("out" . "binary")))

(defvar vscode-icon-file-alist
  '(;; Files.
    (".clang-format" . "cpp")
    (".projectile" . "emacs")
    ("projectile.cache" . "emacs")
    ("gradle.properties" . "gradle")
    ("gradlew" . "gradle")
    ("gradlew.bat" . "gradle")
    (".gitignore" . "git")
    (".gitattributes". "git")
    ("yarn.lock" . "yarn")
    ("Info.plist" . "objectivec")
    ("Cask" . "emacs")
    (".luminus" . "clojure")
    ("Dockerfile" . "docker")
    ("mix.lock" . "elixir")
    ("recentf" . "emacs")
    (".flowconfig" . "flow")
    (".editorconfig" . "editorconfig")
    (".babelrc" . "babel")
    ("cargo.lock" . "cargo")
    (".tramp" . "emacs")
    (".npmignore" . "npm")
    (".npmrc" . "npm")
    ;; Can lowercase if needed in the future.
    ("LICENSE" . "license")
    ("Makefile" . "makefile")
    ;; Extensions.
    ("zsh" . "shell")
    ("rb" . "ruby")
    ("restclient" . "rest")
    ("txt" . "text")
    ("ts" . "typescript")
    ("exs" . "elixir")
    ("cljc" . "clojure")
    ("clj" . "clojure")
    ("cljs" . "clojure")
    ("py" . "python")
    ("sh" . "shell")
    ("md" . "markdown")
    ("yml" . "yaml")
    ("hpp" . "cppheader")
    ("cc" . "cpp")
    ("m" . "objectivec")
    ("png" . "image")
    ("h" . "cppheader")
    ("elc" . "emacs")
    ("el" . "emacs")))

;; Implementation

(defun vscode-icon-for-file (file)
  "Return an vscode icon image given FILE.

Icon Source: https://github.com/vscode-icons/vscode-icons"
  (let ((default-directory
          (if (vscode-icon-can-scale-image-p)
              (concat vscode-icon-dir "128/")
            (concat vscode-icon-dir
                    (number-to-string vscode-icon-size) "/"))))
    (if (file-directory-p file)
        (vscode-icon-dir file)
      (vscode-icon-file file))))

(defun vscode-icon-dir (file)
  "Get directory icon given FILE."
  (vscode-icon-if-let* ((filepath (vscode-icon-dir-exists-p
                                   (file-name-base file))))
      (vscode-icon-create-image filepath)
    (vscode-icon-if-let*
        ((val (cdr (assoc
                    (file-name-base file) vscode-icon-dir-alist))))
        (vscode-icon-if-let* ((filepath (vscode-icon-dir-exists-p val)))
            (vscode-icon-create-image filepath)
          (vscode-icon-default-folder))
      (vscode-icon-default-folder))))

(defun vscode-icon-file (file)
  "Get file icon given FILE."
  (vscode-icon-if-let* ((filepath (vscode-icon-file-exists-p
                                   (file-name-extension file))))
      (vscode-icon-create-image filepath)
    (vscode-icon-if-let*
        ((val (or
               (cdr (assoc (vscode-icon-basefile-with-extension file)
                           vscode-icon-file-alist))
               (cdr (assoc file vscode-icon-file-alist))
               (cdr (assoc (file-name-extension file)
                           vscode-icon-file-alist)))))
        (vscode-icon-if-let* ((filepath (vscode-icon-file-exists-p val)))
            (vscode-icon-create-image filepath)
          (vscode-icon-default-file))
      (vscode-icon-default-file))))

(defun vscode-icon-file-exists-p (key)
  "Check if there is an icon for KEY.

Return filepath of icon if so."
  (let ((path-in-default-dir (expand-file-name (format "file_type_%s.png" key)))
        (path-in-extra-dir (expand-file-name (format "%d/file_type_%s.png"
                                                     vscode-icon-size key)
                                             vscode-icon-extra-icon-directory)))
    (cond
     ((file-exists-p path-in-default-dir) path-in-default-dir)
     ((file-exists-p path-in-extra-dir) path-in-extra-dir)
     (:default nil))))

(defun vscode-icon-dir-exists-p (key)
  "Check if there is an icon for KEY.

Return filepath of icon if so."
  (let ((path-in-default-dir (expand-file-name (format "folder_type_%s.png" key)))
        (path-in-extra-dir (expand-file-name (format "%d/folder_type_%s.png"
                                                     vscode-icon-size key)
                                             vscode-icon-extra-icon-directory)))
    (cond
     ((file-exists-p path-in-default-dir) path-in-default-dir)
     ((file-exists-p path-in-extra-dir) path-in-extra-dir)
     (:default nil))))

(defun vscode-icon-create-image (filename)
  "Helper method to create and return an image given FILENAME."
  (let ((scale (vscode-icon-get-scale vscode-icon-size)))
    (create-image filename 'png nil :scale scale :ascent 'center)))

(defun vscode-icon-default-folder ()
  "Return image for default folder."
  (vscode-icon-create-image (expand-file-name "default_folder.png")))

(defun vscode-icon-default-file ()
  "Return image for default file."
  (vscode-icon-create-image (expand-file-name "default_file.png")))

(defun vscode-icon-can-scale-image-p ()
  "Return whether or not Emacs can scale images."
  (cond
   ((eq system-type 'darwin)
    (or (image-type-available-p 'imagemagick)
        ;; Emacs 27 (OSX) supports resizing images without `imagemagick'.
        ;; e4f2061ebc * | | Add image resizing and rotation to NS port
        ;; Git Hash: e4f2061ebc61168f23c0d9440221cbc99864deae
        (and
         (fboundp 'image-transforms-p)
         (image-transforms-p))))
   (:default
    (and
     ;; Emacs 27 only.
     (fboundp 'image-transforms-p)
     (image-transforms-p)))))

(defun vscode-icon-get-scale (image-size)
  "Get scale according to IMAGE-SIZE."
  (/ (/ image-size 1.0) 128))

(defun vscode-icon-basefile-with-extension (file)
  "Return base filename with extension given FILE.

: ~/a/b.json -> b.json

If there is no extension, just return the base file name."
  (let ((base (file-name-base file))
        (ext (file-name-extension file)))
    (if (and base ext)
        (format "%s.%s" base ext)
      base)))

(defun vscode-icon-convert-from-big-png (icon-size)
  "Convert svg images to pngs sizing them to ICON-SIZE."
  (unless (executable-find "convert")
    (user-error "Executable convert not found! Install imagemagick? "))
  (let ((default-directory vscode-icon-root)
        (target-directory
         (if icon-size
             (expand-file-name (format "icons/%d" icon-size) vscode-icon-root)
           (expand-file-name "icons" vscode-icon-root))))
    (unless (file-directory-p target-directory)
      (make-directory target-directory)))
  (mapcar
   (lambda (file)
     (let ((ext (file-name-extension file))
           (base (file-name-base file)))
       (when (equal ext "png")
         (let* ((density (* icon-size 3))
                ;; `imagemagick' takes a percentage but `vscode-icon-get-scale'
                ;; returns a decimal, so multiply by 100.
                ;; ex. .18 --> 18
                (scale (truncate (* 100 (vscode-icon-get-scale icon-size))))
                (command
                 (format
                  "convert -depth 8 -density %d -background transparent -scale %d%% %s PNG32:%s"
                  density
                  scale
                  file
                  (format "%sicons/%d/%s.png" vscode-icon-root icon-size base))))
           (let ((result (shell-command command)))
             `(,command . ,result))))))
   (directory-files (format "%sicons/128/" vscode-icon-root) t)))

(defun vscode-icon-create-source-pngs (&optional force)
  "Create source png from svg to convert to smaller icons.

Only create source icons if FORCE is non nil or if the directory is empty.

i.e. Don't create source pngs if there are already source pngs created."
  (unless (executable-find "convert")
    (user-error "Executable convert not found! Install imagemagick? "))
  (let ((default-directory vscode-icon-root)
        (target-directory (expand-file-name "icons/128" vscode-icon-root)))
    (unless (file-directory-p target-directory)
      (make-directory target-directory))
    (if (and (not force)
             (> (length (directory-files target-directory)) 2))
        'skip
      (mapcar
       (lambda (file)
         (let ((ext (file-name-extension file))
               (base (file-name-base file)))
           (when (equal ext "svg")
             (let* ((density (* 128 3))
                    (command
                     (format
                      "convert -depth 8 -density %d -background transparent -size 128x128 %s PNG32:%s"
                      density
                      file
                      (format "%sicons/128/%s.png" vscode-icon-root base))))
               (let ((result (shell-command command)))
                 `(,command . ,result))))))
       (directory-files vscode-icon-source-dir t)))))

(defun vscode-icon-convert-icons-async (&optional convert-size copy)
  "Run `vscode-icon-create-source-pngs', `vscode-icon-convert-from-big-png'\

and `vscode-icon-copy-icons-to-user-directory' in another Emacs process."
  (interactive "nIcon Size: ")
  (if (fboundp 'async-start)
      (async-start
       `(lambda ()
          (load ,(locate-library "vscode-icon"))
          (require 'vscode-icon)
          (vscode-icon-create-source-pngs))
       (lambda (create-source-icon-result)
         (if (eq create-source-icon-result 'skip)
             (message "Skipped creating source pngs... Converting icons..")
           (message "Finished creating source pngs.. Converting icons.."))
         (mapcar
          (lambda (icon-size)
            (async-start
             `(lambda ()
                (load ,(locate-library "vscode-icon"))
                (require 'vscode-icon)
                (vscode-icon-convert-from-big-png ,icon-size))
             `(lambda (result)
                (message "Finished converting icons. Result: %s" result)
                (when ,copy
                  (vscode-icon-copy-icons-to-user-directory)))))
          `(,(if convert-size convert-size 23)))))
    (user-error "Package `async' not installed? ")))

(defun vscode-icon-copy-icons-to-user-directory ()
  "Copy `vscode-icon-dir' to `vscode-icon-extra-icon-directory'.

This is useful after generating icons of a different size with
`vscode-icon-convert-icons-async'."
  (interactive)
  (if (fboundp 'async-start)
      (progn
        (message "Copying icons asynchronously..")
        (async-start `(lambda ()
                        (load ,(locate-library "vscode-icon"))
                        (require 'vscode-icon)
                        (copy-directory ,vscode-icon-dir
                                        ,vscode-icon-extra-icon-directory t t t))
                     (lambda (_)
                       (message "Finished copying icons."))))
    (user-error "Package `async' not installed? ")))

(defun vscode-icon-convert-and-copy (&optional convert-size)
  "Run `vscode-icon-convert-icons-async' and then \
copy those icons to `vscode-icon-extra-icon-directory'."
  (interactive "nIcon Size: ")
  (vscode-icon-convert-icons-async convert-size :copy))

(provide 'vscode-icon)
;;; vscode-icon.el ends here
