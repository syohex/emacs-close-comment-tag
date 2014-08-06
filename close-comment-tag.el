;;; close-comment-tag.el --- Insert close comment tag

;; Copyright (C) 2014 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>
;; URL: https://github.com/syohex/
;; Version: 0.01

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

;;; Code:

(require 'sgml-mode)

(defun close-comment-tag--retrieve-attributes (attribute start)
  (let ((bound (save-excursion (forward-list) (point))))
    (save-excursion
      (goto-char start)
      (let ((attrs nil)
            (re (concat attribute
                        "\\s-*=\\s-*\\(?:\"\\([^\"]+\\)\"\\|\\(\\S-+\\)\\)")))
        (while (re-search-forward re bound t)
          (let ((value (or (match-string 1) (match-string 2))))
            (setq attrs (append (split-string value) attrs))))
        attrs))))

(defun close-comment-tag--tag-name ()
  (skip-chars-forward " \t\n\r")
  (let ((start (point)))
    (skip-chars-forward "^/> \t\n\r")
    (buffer-substring-no-properties start (point))))

(defun close-comment-tag--validate (orig-point)
  (save-excursion
    (let ((tagname (progn
                     (down-list)
                     (close-comment-tag--tag-name))))
      (goto-char orig-point)
      (unless (looking-at-p (concat "\\s-*</" tagname "\\s-*>"))
        (error "Here is not close tag")))))

(defun close-comment-tag--construct-comment (id classes)
  (concat "<!-- /"
          (and id (concat "#" id))
          (and (and id classes) ".")
          (and classes (mapconcat 'identity classes "."))
          " -->"))

;;;###autoload
(defun close-comment-tag ()
  (interactive)
  (let ((curpoint (point)))
    (save-excursion
      (sgml-skip-tag-backward 1)
      (let ((start (point)))
        (close-comment-tag--validate curpoint)
        (let* ((ids (close-comment-tag--retrieve-attributes "id" start))
               (classes (close-comment-tag--retrieve-attributes "class" start))
               (comment (close-comment-tag--construct-comment (car ids) classes)))
          (goto-char curpoint)
          (insert comment))))))

(provide 'close-comment-tag)

;;; close-comment-tag.el ends here
