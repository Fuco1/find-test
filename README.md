# find-test

Simple package for jumping between implementations and tests.

# Usage

Use `ft-find-test-or-source` to jump between source and test file.

# How does it work

The approach taken in this package is very simple.  We opted for a little bit of configuration over unnecessary complexity in trying to be too smart.  This also allows us to be much more flexible in projects using mixed languages or non-standard layouts.

# Example configuration

We can set up mappings for a project with multiple languages easily by major mode.  Special subdirectories can be given different mappings as well.

``` emacs-lisp
;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((php-mode
  (ft-source-to-test-mapping . ((:path "/app/" :suffix ".php") . (:path "/tests/php/" :suffix ".phpt"))))
 (js-mode
  (ft-source-to-test-mapping . ((:path "/www/js/" :suffix ".js") . (:path "/tests/js/" :suffix ".spec.js"))))
 ("libs"
  (php-mode
   (ft-source-to-test-mapping . ((:path "/libs/" :suffix ".php") . (:path "/tests/php/" :suffix ".phpt")))))
 ("tests/php/libs"
  (php-mode
   (ft-source-to-test-mapping . ((:path "/libs/" :suffix ".php") . (:path "/tests/php/" :suffix ".phpt"))))))
```
