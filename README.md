# find-test

Simple package for jumping between implementations and tests.

# Usage

Use `ft-find-test-or-source` to jump between source and test file.

# How does it work

The approach taken in this package is very simple.  We opted for a little bit of configuration over unnecessary complexity in trying to be too smart.  This also allows us to be much more flexible in projects using mixed languages or non-standard layouts.

# Configuration

Configuration is stored in a single buffer-local variable `ft-source-to-test-mapping`.  Its value should be a `cons` with two plists, where:

* `car` is the description of the source file,
* `cdr` is the description of the test file.

Both of these plists can contain these keys:

* `:path` - part of the full path to the file
* `:prefix` - prefix of the file
* `:suffix` - suffix of the file, including the extension

Whether a file is a source or test file is determined by first
matching the path to the file to the `:path` property and then
matching the `:prefix` and `:suffix`.

To compute the test file name from source file name the `:path`
property of the source file is string-replaced with the test file
`:path` property and then the source suffix is replaced with the test
suffix and vice versa; the same for the prefix.

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

These are some of the translations:

- `/home/matus/app/Entity/Foo.php` => `/home/matus/tests/php/Foo.phpt`
- `/home/matus/libs/Common/Bar.php` => `/home/matus/tests/php/Common/Bar.phpt`
- `/home/matus/www/js/Entity/Foo.js` => `/home/matus/tests/js/Entity.spec.js`

# Related work

## find-file

The built-in package `find-file` provides a method `ff-find-other-file` which can be configured to behave somewhat similarly to the above.  However, the configuration process is rather painful as the primary purpose of that package was to jump between `.c` and `.h` files and so it assumes quite a lot of things which are not universally true.

Originally I ment to write this package as a configuration layer sitting above `find-file` (similar to how [shackle](https://github.com/wasamasa/shackle) sits on top of `display-buffer-alist`) but ultimately decided against it as the size of the implementation is currently less than 200 lines and is very very simple.

## projectile

The [projectile](https://github.com/bbatsov/projectile) project provides the functionality to jump between source and test files as well but the way it is implemented does not lend very well to projects which use multiple languages or non-standard layouts.  It *can* be configured to do what you want after some effort but that effort was too much for me.  Also, the project is rather huge and comes with a lot of features one might not necessarily need.  This project provides a very light and flexible alternative.
