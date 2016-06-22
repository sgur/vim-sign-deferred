vim-sign-deferred
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
| g:sign_deferred_insert_symbol            | `+`     |
| g:sign_deferred_delete_first_line_symbol | `‾`     |
| g:sign_deferred_delete_symbol            | `_`     |
| g:sign_deferred_modify_symbol            | `!`     |

```vim
let g:sign_deferred_insert_symbol='⇒'
let g:sign_deferred_delete_first_line_symbol='⇐'
let g:sign_deferred_delete_symbol='⇐'
let g:sign_deferred_modify_symbol='⇔'
```

### Customize highlight group

| Highlight group name     | Default                 |
|--------------------------|-------------------------|
| SignDeferredInserted | linking to `DiffAdd`    |
| SignDeferredDelete   | Linking to `DiffDelete` |
| SignDeferredModify   | Linking to `DiffChange` |

```vim
highlight SignDeferredInserted guifg=green
highlight SignDeferredDelete guifg=red
highlight SignDeferredModify guifg=orange
```

Install
-------

License
-------

[MIT License](./LICENSE)

Author
------

