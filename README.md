# Further.vim
Follows imports to their source for seamless file hopping

## Purpose
Vim's built-in `gf` mapping doesn't play nicely with JavaScript. File extensions are implied, and modules are are a tangled symlinked mess inside `node_modules`.

> **Note:** `gf` opens the file name under the cursor. Try `:help gf` for more info.

This plugin calls through to Node's module resolution algorithm. If the path works in Node, it'll work with `gf`.
