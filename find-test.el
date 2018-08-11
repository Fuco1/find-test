;;; find-test.el --- Jump between source and test files -*- lexical-binding: t -*-

;; Copyright (C) 2017 Matúš Goljer

;; Author: Matúš Goljer <matus.goljer@gmail.com>
;; Maintainer: Matúš Goljer <matus.goljer@gmail.com>
;; Version: 0.0.1
;; Created: 17th August 2017
;; Package-requires: ((dash "2.10.0"))
;; Keywords: files, convenience

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'dash)
(require 'find-file)

(defvar ft-source-to-test-mapping nil
  "Mapping determining source to test file conversion.

A `cons' with two plists:

- `car' is the description of the source file
- `cdr' is the description of the test file.

Both of these plists can contain these keys:

- :path - part of the full path to the file
- :prefix - prefix of the file
- :suffix - suffix of the file, including the extension

Whether a file is a source or test file is determined by first
matching the path to the file to the :path property and then
matching the :prefix and :suffix.

To compute the test file name from source file name the :path
property of the source file is string-replaced with the test
file :path property and then the source suffix is replaced with
the test suffix and vice versa; the same for the prefix.")

(defun ft-plist-p (list)
  "Non-null if and only if LIST is a plist with string values"
  (while (consp list)
    (setq list (if (and (keywordp (car list))
                        (stringp (cdr list)))
                   (cddr list)
                 'not-plist)))
  (null list))

(put 'ft-source-to-test-mapping 'safe-local-variable
     (lambda (x)
       (and (consp x)
            (listp (car x))
            (listp (cdr x))
            (ft-plist-p (car x))
            (ft-plist-p (cdr x)))))

(cl-defstruct ft-definition path prefix suffix)

(defun ft--definition (plist)
  (make-ft-definition
   :path (plist-get plist :path)
   :prefix (plist-get plist :prefix)
   :suffix (plist-get plist :suffix)))

(defun ft-source-definition (&optional buffer)
  (setq buffer (or buffer (current-buffer)))
  (with-current-buffer buffer
    (ft--definition (car ft-source-to-test-mapping))))

(defun ft-test-definition (&optional buffer)
  (setq buffer (or buffer (current-buffer)))
  (with-current-buffer buffer
    (ft--definition (cdr ft-source-to-test-mapping))))

(defun ft--get-suffix-regexp (definition)
  (concat (regexp-quote (ft-definition-suffix definition)) "\\'"))

(defun ft--get-prefix-regexp (definition)
  (regexp-quote (ft-definition-prefix definition)))

(defun ft--definition-match-p (file definition)
  (and (string-match-p (ft-definition-path definition) file)
       (or (not (ft-definition-prefix definition))
           (string-match-p (ft--get-prefix-regexp definition)
                           (file-name-nondirectory file)))
       (or (not (ft-definition-suffix definition))
           (string-match-p (ft--get-suffix-regexp definition)
                           (file-name-nondirectory file)))))

(defun ft-source-p (&optional file)
  (setq file (or file (buffer-file-name)))
  (ft--definition-match-p file (ft-source-definition)))

(defun ft-test-p (&optional file)
  (setq file (or file (buffer-file-name)))
  (ft--definition-match-p file (ft-test-definition)))

(defun ft--get-source-file (file)
  (let ((source (ft-source-definition))
        (test (ft-test-definition)))
    (when (and (ft-definition-suffix source)
               (ft-definition-suffix test))
      (setq file
            (replace-regexp-in-string
             (ft--get-suffix-regexp test)
             (ft-definition-suffix source)
             file)))
    (when (and (ft-definition-prefix source)
               (ft-definition-prefix test))
      (let* ((basename (file-name-nondirectory (directory-file-name file)))
             (new-basename
              (replace-regexp-in-string
               (ft--get-prefix-regexp test)
               (ft-definition-prefix source)
               basename)))
        (setq file (replace-regexp-in-string (regexp-quote basename) new-basename file))))
    (replace-regexp-in-string
     (ft-definition-path test)
     (ft-definition-path source)
     file)))

(defun ft--get-test-file (file)
  (let ((source (ft-source-definition))
        (test (ft-test-definition)))
    (when (and (ft-definition-suffix source)
               (ft-definition-suffix test))
      (setq file
            (replace-regexp-in-string
             (ft--get-suffix-regexp source)
             (ft-definition-suffix test)
             file)))
    (when (and (ft-definition-prefix source)
               (ft-definition-prefix test))
      (let* ((basename (file-name-nondirectory (directory-file-name file)))
             (new-basename
              (replace-regexp-in-string
               (ft--get-prefix-regexp source)
               (ft-definition-prefix test)
               basename)))
        (setq file (replace-regexp-in-string (regexp-quote basename) new-basename file))))
    (replace-regexp-in-string
     (ft-definition-path source)
     (ft-definition-path test)
     file)))

(defun ft-get-test-or-source (&optional file)
  (setq file (or file (buffer-file-name)))
  (cond
   ((ft-source-p file)
    (ft--get-test-file file))
   ((ft-test-p file)
    (ft--get-source-file file))
   (:else (user-error "Unable to determine whether the file is source or test"))))

(defun ft-get-test-file (&optional file)
  (setq file (or file (buffer-file-name)))
  (cond
   ((ft-source-p file)
    (ft--get-test-file file))
   ((ft-test-p file)
    file)
   (:else (user-error "Unable to determine whether the file is source or test"))))

(defun ft-get-source-file (&optional file)
  (setq file (or file (buffer-file-name)))
  (cond
   ((ft-source-p file)
    file)
   ((ft-test-p file)
    (ft--get-source-file file))
   (:else (user-error "Unable to determine whether the file is source or test"))))

(defun ft-find-test-or-source ()
  (interactive)
  (find-file (ft-get-test-or-source)))

(provide 'find-test)
;;; find-test.el ends here
