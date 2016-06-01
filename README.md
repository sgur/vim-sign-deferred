vim-difflam
===========

Adding signs asynchronously on the SignColumn area which mark changed from the repository.

Description
-----------

Demo
----

Requirement
-----------

- Git
- Vim built with the `+job` feature
- Vim version 7.4.1828 or later (recommended)

Usage
-----

### Option

Modify sign text for (insert/delete/modify)

| Variable name                           | Default |
|-----------------------------------------|---------|
| g:difflam_sign_insert_symbol            | `+`     |
| g:difflam_sign_delete_first_line_symbol | `‾`     |
| g:difflam_sign_delete_symbol            | `_`     |
| g:difflam_sign_modify_symbol            | `!`     |

Install
-------

License
-------

[MIT License](./LICENSE)

Author
------

