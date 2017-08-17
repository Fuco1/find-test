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
 ("tests/php/Common"
  (php-mode
   (ft-source-to-test-mapping . ((:path "/libs/" :suffix ".php") . (:path "/tests/php/" :suffix ".phpt"))))))
```

# Related work

## find-file

The built-in package `find-file` provides a method `ff-find-other-file` which can be configured to behave somewhat similarly to the above.  However, the configuration process is rather painful as the primary purpose of that package was to jump between `.c` and `.h` files and so it assumes quite a lot of things which are not universally true.

Originally I ment to write this package as a configuration layer sitting above `find-file` (similar to how [shackle](https://github.com/wasamasa/shackle) sits on top of `display-buffer-alist`) but ultimately decided against it as the size of the implementation is currently less than 200 lines and is very very simple.

## projectile

The [projectile](https://github.com/bbatsov/projectile) project provides the functionality to jump between source and test files as well but the way it is implemented does not lend very well to projects which use multiple languages or non-standard layouts.  It *can* be configured to do what you want after some effort but that effort was too much for me.  Also, the project is rather huge and comes with a lot of features one might not necessarily need.  This project provides a very light and flexible alternative.
