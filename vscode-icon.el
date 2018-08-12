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

(defcustom vscode-icon-scale .18
  "The scale of icons.

This takes effect if `imagemagick' support is available."
  :type 'number
  :group 'vscode-icon)

(defcustom vscode-icon-size 26
  "The size of the icon when creating an icon.

This only takes effect if `imagemagick' support is not available."
  :type 'number
  :group 'vscode-icon)

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
    ;; Can lowercase if needed in the future.
    ("LICENSE" . "license")
    ("Makefile" . "makefile")
    ;; Extensions.
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
    ("hpp" . "cpp2")
    ("cc" . "cpp")
    ("m" . "objectivec")
    ("png" . "image")
    ("h" . "cppheader")
    ("elc" . "emacs")
    ("el" . "emacs")))

(defun vscode-icon-for-file (file)
  "Return an vscode icon image given FILE.

Icon Source: https://github.com/vscode-icons/vscode-icons"
  (let ((default-directory
          (if (image-type-available-p 'imagemagick)
              (concat vscode-icon-dir "128/")
            (concat vscode-icon-dir
                    (number-to-string vscode-icon-size) "/"))))
    (if (file-directory-p file)
        (vscode-icon-dir file)
      (vscode-icon-file file))))

(defun vscode-icon-dir (file)
  "Get directory icon given FILE."
  (if (vscode-icon-dir-exists-p (file-name-base file))
      (vscode-icon-get-dir-image (file-name-base file))
    (if-let ((val (cdr (assoc
                        (file-name-base file) vscode-icon-dir-alist))))
        (if (vscode-icon-dir-exists-p val)
            (vscode-icon-get-dir-image val)
          (vscode-icon-default-folder))
      (vscode-icon-default-folder))))

(defun vscode-icon-file (file)
  "Get file icon given FILE."
  (if (vscode-icon-file-exists-p (file-name-extension file))
      (vscode-icon-get-file-image (file-name-extension file))
    (if-let ((val (or
                   (cdr (assoc (vscode-icon-basefile-with-extension file)
                               vscode-icon-file-alist))
                   (cdr (assoc file vscode-icon-file-alist))
                   (cdr (assoc (file-name-extension file)
                               vscode-icon-file-alist)))))
        (if
            (vscode-icon-file-exists-p val)
            (vscode-icon-get-file-image val)
          (vscode-icon-default-file))
      (vscode-icon-default-file))))

(defun vscode-icon-get-dir-image (key)
  "Return icon for KEY."
  (vscode-icon-create-image
   (expand-file-name (format "folder_type_%s.png" key))))

(defun vscode-icon-get-file-image (key)
  "Return icon for KEY."
  (vscode-icon-create-image
   (expand-file-name (format "file_type_%s.png" key))))

(defun vscode-icon-file-exists-p (key)
  "Check if there is an icon for KEY."
  (file-exists-p (expand-file-name (format "file_type_%s.png" key))))

(defun vscode-icon-dir-exists-p (key)
  "Check if there is an icon for KEY."
  (file-exists-p (expand-file-name (format "folder_type_%s.png" key))))

(defun vscode-icon-create-image (filename)
  "Helper method to create and return an image given FILENAME."
  (let ((scale vscode-icon-scale))
    (create-image filename 'png nil :scale scale :ascent 'center)))

(defun vscode-icon-default-folder ()
  "Return image for default folder."
  (vscode-icon-create-image (expand-file-name "default_folder.png")))

(defun vscode-icon-default-file ()
  "Return image for default file."
  (vscode-icon-create-image (expand-file-name "default_file.png")))

(defun vscode-icon-basefile-with-extension (file)
  "Return base filename with extension given FILE.

ex. ~/a/b.json -> b.json

If there is no extension, just return the base file name."
  (let ((base (file-name-base file))
        (ext (file-name-extension file)))
    (if (and base ext)
        (format "%s.%s" base ext)
      base)))

(defun vscode-icon-convert-icons-from-svg-to-png (icon-size)
  "Convert svg images to pngs sizing them to ICON-SIZE."
  (unless (executable-find "svgexport")
    (user-error "svgexport not found!"))
  (unless (executable-find "convert")
    (user-error "convert not found! Install imagemagick to use convert."))
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
       (when (equal ext "svg")
         (let ((density (* icon-size 3)))
           (shell-command
            (format
             "convert -density %d -background none -size %d %s %s"
             density
             icon-size
             file
             (format "%sicons/%d/%s.png" vscode-icon-root icon-size base)))))))
   (directory-files vscode-icon-source-dir t)))

(defun vscode-icon-convert-icons-from-svg-to-png-async ()
  "Run `vscode-icon-convert-icons-from-svg-to-png' in another Emacs process."
  (interactive)
  (if (fboundp 'async-start)
      (mapcar
       (lambda (icon-size)
         (async-start
          `(lambda ()
             (load ,(locate-library "vscode-icon"))
             (require 'vscode-icon)
             (vscode-icon-convert-icons-from-svg-to-png ,icon-size))
          (lambda (result)
            (message "Finished converting icons. Result: %s" result))))
       '(26 128))
    (user-error "Package `async' not installed.")))

(provide 'vscode-icon)
;;; vscode-icon.el ends here
