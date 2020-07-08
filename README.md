# Further.vim
Follow JavaScript imports to their source.

## Purpose
The `gf` mapping in vim edits the file under your cursor, but it doesn't work
in JavaScript. Node's module resolution is too complex for Vim to generalize.

`further.vim` teaches Vim how to navigate JavaScript modules by replacing the
built-in `gf` mapping with a full Vimscript implementation of Node's [module
resolution
algorithm](https://nodejs.org/api/modules.html#modules_all_together).

---

TL;DR:
- Put cursor over JavaScript import
- Press `gf`
- Vim opens the file

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

## FAQ
<dl>
  <dt>Does it work with TypeScript?</dt>
  <dd>Yeah</dd>

  <dt>How do I add support for new file extensions?</dt>
  <dd>
    <pre lang="viml"><code>let g:further#extensions = ['.like-this']</code></pre>
  </dd>

  <dt>How do I open a file in a new split?</dt>
  <dd>Try <code>&lt;c-w&gt;gf</code></dd>

  <dt>Is there a programmatic API?</dt>
  <dd><code>:help further-functions</code></dd>

  <dt>Does it work with <a href="https://yarnpkg.com/features/pnp">Plug'n'Play</a>?</dt>
  <dd>No.</dd>

  <dt>Anything else I should know?</dt>
  <dd>Sometimes dolphins use pufferfish to get high.</dd>
</dl>

## Documentation
All the docs are in the `further` help page. Install the plugin then run:
```viml
:help further.vim
```

## Customization
Further works out of the box, but if you want, you can completely customize
resolution on a global or per-module basis. For instance: you could open
`src/` instead of `dist/`, rewrite monorepo imports, or resolve paths to
a different repository entirely.

Check out `:help further-advanced` for details.

## Help
If something isn't working, send me an issue and I'll do my best to help.
