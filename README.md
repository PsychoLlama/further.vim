# Further.vim
Follow JavaScript imports to their source

## Purpose
The `gf` mapping in vim edits the file under your cursor, but it doesn't work
well in JavaScript. File extensions are implied, `node_modules` directories
can be nested beneath themselves, and there can be different package versions
depending on what symlink you follow.

`further.vim` aims for seamless JavaScript imports traversal, replacing the
built-in `gf` mapping with the JS module resolution algorithm. But, you know,
only in JavaScript files.

## Monorepos
further.vim exposes a hook: you can intercept and transform file paths before
they're opened. This is incredibly useful for monorepos. Importing a package
inside the same repo will probably take you to transpiled code, but that's not
optimized for a human.

By registering a function, you can redirect from transpiled code to the source
code instantly. Sample function:

```viml
" If the import name contains the string 'some-pkg-name', replace
" 'compiled/' with 'source-code/' in the file path.
function! g:FurtherMapModuleName(resolved, import_name)
  if a:import_name =~# 'some-pkg-name'
    return substitute(a:resolved, 'compiled/', 'source-code/', '')
  endif

  return a:resolved
endfunction
```

## Installation
**vim-plug**
```viml
Plug 'PsychoLlama/further.vim'
```

**vundle**
```viml
Plugin 'PsychoLlama/further.vim'
```

**pathogen**
```
I totally forgot how pathogen works.
```

## Documentation
All the docs are in the `further` help page. Install the plugin then run:
```viml
:help further.vim
```

## Contributing
Find a bug or have a question? I'd love to help! Submit an issue and we can
brainstorm a solution.

Thanks for being a cool user. High five :raised_hand:
