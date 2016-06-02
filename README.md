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

#### Customize sign text

| Variable name                           | Default |
|-----------------------------------------|---------|
| g:difflam_sign_insert_symbol            | `+`     |
| g:difflam_sign_delete_first_line_symbol | `‾`     |
| g:difflam_sign_delete_symbol            | `_`     |
| g:difflam_sign_modify_symbol            | `!`     |

```vim
let g:difflam_sign_insert_symbol='⇒'
let g:difflam_sign_delete_first_line_symbol='⇐'
let g:difflam_sign_delete_symbol='⇐'
let g:difflam_sign_modify_symbol='⇔'
```

### Customize highlight group

| Highlight group name | Default                 |
|----------------------|-------------------------|
| DifflamSignInserted  | linking to `DiffAdd`    |
| DifflamSignDelete    | Linking to `DiffDelete` |
| DifflamSignModify    | Linking to `DiffChange` |

```vim
highlight DifflamSignInserted guifg=green
highlight DifflamSignDelete guifg=red
highlight DifflamSignModify guifg=orange
```

Install
-------

License
-------

[MIT License](./LICENSE)

Author
------

