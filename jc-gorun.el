;;; jc-gorun.el --- run go code and show output at the end of the file

;; Copyright 2017 John Cinnamond

;; Author: John Cinnamond
;; Version: 1.0.0

;;; Commentary:
;;
;; Adds a function to run the current go code and show the output as a
;; comment at the end of the file, intended for live coding.

;;; License:

;; This file is not part of GNU Emacs.
;; However, it is distributed under the same license.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:

(defun jc-gorun-run ()
  "Run the current file with go run and add any output to the buffer"
  (interactive)
  (save-buffer)
  (jc-gorun-cleanup)
  (save-excursion
    (goto-char (point-max))
    (jc-gorun--insert-header)
    (jc-gorun--insert-result)))

(defun jc-gorun-cleanup ()
  (interactive)
  (save-excursion
    (goto-char (point-max))
    (if (search-backward (jc-gorun--format "Output") nil t)
	(delete-char (- (point-max) (point))))))

(defun jc-gorun--insert-header ()
  (if (jc-gorun--need-blank-line-p)
      (newline))
  (jc-gorun--insert-line "Output")
  (jc-gorun--insert-line ""))

(defun jc-gorun--insert-line (s)
  (insert (jc-gorun--format s))
  (newline))

(defun jc-gorun--format (s)
  (concat "// >> " s))

(defun jc-gorun--insert-result ()
  (seq-do (lambda (x) (jc-gorun--insert-line x)) (jc-gorun--result-lines)))

(defun jc-gorun--compile ()
  (shell-command-to-string (concat "go run " buffer-file-name)))

(defun jc-gorun--result-lines ()
  (split-string (jc-gorun--compile) "[\r\n]+"))

(defun jc-gorun--need-blank-line-p ()
  (not (string-match-p "^[\r\n]\\{2\\}$" (buffer-substring-no-properties (- (point) 2) (point)))))

(define-minor-mode jc-gorun
  "run go code and show the output"
  nil ; initially disabled
  " jc-gorun")

(provide 'jc-gorun)
;;; jc-gorun.el ends here
