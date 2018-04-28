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

## Redirects
Most libraries will resolve to a babel-compiled file. Efficient, but not easily
readable by humans.

`further.vim` exposes a hook for this. Defining a special function allows you
to intercept the resolved file path and change it to something else.

The easiest way is just replacing `dist/` with `src/` and seeing if it
resolves to an actual file. If not, just return it unchanged.

```viml
" Replace 'dist/' with 'src/', unless that results in an unreadable file.
function! g:FurtherMapModuleName(file_path, module_name)
  let l:sourcified = substitute(a:file_path, '/dist/', '/src/', '')

  if filereadable(l:sourcified)
    return l:sourcified
  endif

  return a:file_path
endfunction
```

Intercepts are even more useful when the pathname can't be known without
app-specific knowledge, like the location of AngularJS html templates, or
a config file with implied directory prefixes.

If you're unsure how to use the intercept function, open an issue. I'm more
than willing to help!

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
```sh
git clone https://github.com/psychollama/further.vim ~/.vim/bundle/
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
