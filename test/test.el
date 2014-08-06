;;; test.el --- test for close-comment-tag.el

;; Copyright (C) 2014 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>

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

(require 'ert)
(require 'close-comment-tag)

(ert-deftest retrieve-tag-name ()
  "retrieve tag name"
  (with-html-temp-buffer
    "
<html>
</html>"

    (forward-cursor-on "html")
    (should (string= (close-comment-tag--tag-name) "html"))))

(ert-deftest retrieve-tag-name-has-attributes ()
  "retrieve tag name which has some attributes"
  (with-html-temp-buffer
    "
<div id=\"top\" class=\"foo bar\">
</div>"

    (forward-cursor-on "div")
    (should (string= (close-comment-tag--tag-name) "div"))))

(ert-deftest retrieve-tag-name-no-end-tag ()
  "retrieve tag name which has no end tag"
  (with-html-temp-buffer
    "
<br />
"

    (forward-cursor-on "br")
    (should (string= (close-comment-tag--tag-name) "br"))))

(ert-deftest retrieve-tag-attribute ()
  "retrieve tag attribute"
  (with-html-temp-buffer
    "
<div id=\"top\" class=\"foo bar\" name=\"baz\">
</div>"

    (forward-cursor-on "<div")
    (let ((start (point)))
      (let ((got (close-comment-tag--retrieve-attributes "id" start)))
        (should (= (length got) 1))
        (should (string= (car got) "top")))

      (let ((got (close-comment-tag--retrieve-attributes "class" start)))
        (should (= (length got) 2))
        (should (equal got '("foo" "bar"))))

      (let ((got (close-comment-tag--retrieve-attributes "name" start)))
        (should (= (length got) 1))
        (should (string= (car got) "baz"))))))

(ert-deftest construct-comment-with-id-and-classes ()
  "construct comment with id and classes"
  (let ((got (close-comment-tag--construct-comment "foo" '("bar" "baz"))))
    (should (string= got "<!-- /#foo.bar.baz -->"))))

(ert-deftest construct-comment-with-only-id ()
  "construct comment with id"
  (let ((got (close-comment-tag--construct-comment "foo" nil)))
    (should (string= got "<!-- /#foo -->"))))

(ert-deftest construct-comment-with-only-classes ()
  "construct comment with classes"
  (let ((got (close-comment-tag--construct-comment nil '("bar" "baz"))))
    (should (string= got "<!-- /bar.baz -->"))))

(ert-deftest construct-comment-with-nothing ()
  "construct comment with nothing"
  (let ((got (close-comment-tag--construct-comment nil nil)))
    (should (string= got "<!-- / -->"))))

(ert-deftest close-comment-tag ()
  "retrieve tag attribute"
  (with-html-temp-buffer
    "
<div id=\"top\" class=\"foo bar\">
Foo
</div>"

    (forward-cursor-on "</div")
    (call-interactively 'close-comment-tag)
    (let ((expected "
<div id=\"top\" class=\"foo bar\">
Foo
<!-- /#top.foo.bar --></div>"))
      (should (string= (substring-no-properties (buffer-string)) expected)))))

(ert-deftest close-comment-tag-error ()
  "retrieve tag attribute"
  (with-html-temp-buffer
    "
<div id=\"top\" class=\"foo bar\">
Foo
</div>"

    (goto-char (point-max))
    (should-error (call-interactively 'close-comment-tag))))
;;; test.el ends here
