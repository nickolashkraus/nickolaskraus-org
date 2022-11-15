---
title: "Vim Plugins That I Use - 2018"
date: 2018-10-28T00:00:00-06:00
draft: false
description: A complete guide to the Vim plugins that I use.
aliases: ["./vim-plugins-that-i-use"]
---

I find the conceit in using the word *essential* off-putting. Essential implies that it is absolutely necessary. Plugins are not absolutely necessary in order to derive substantial value from Vim. For this reason, this article is humbly titled *Vim Plugins That I Use* and not *Essential Vim Plugins*. Like psilocybin (or any recreational drug for that matter), Vim plugins are used to enhance your experience. However, as a firm grounding in reality is prerequisite before entering pharmacologically induced states of altered consciousness, a strong grasp of pure Vim is necessary before experimenting with the vast bevy of plugins.

The following is a catalog of the Vim plugins that I use and how to use them. They are trifurcated between productivity, code formatting, and appearance.

**Productivity**

* [YouCompleteMe]({{< ref "#YouCompleteMe" >}})
* [ack.vim]({{< ref "#ack.vim" >}})
* [auto-pairs]({{< ref "#auto-pairs" >}})
* [nerdtree]({{< ref "#nerdtree" >}})
* [syntastic]({{< ref "#syntastic" >}})
* [vim-anyfold]({{< ref "#vim-anyfold" >}})
* [vim-fugitive]({{< ref "#vim-fugitive" >}})
* [vim-surround]({{< ref "#vim-surround" >}})
* [vitality.vim]({{< ref "#vitality.vim" >}})

**Code Formatting**

* [vim-autoformat]({{< ref "#vim-autoformat" >}})
* [vim-python-pep8-indent]({{< ref "#vim-python-pep8-indent" >}})

**Appearance**

* [lightline.vim]({{< ref "#lightline.vim" >}})
* [nerdtree-git-plugin]({{< ref "#nerdtree-git-plugin" >}})
* [vim-colors-solarized]({{< ref "#vim-colors-solarized" >}})
* [vim-gitgutter]({{< ref "#vim-gitgutter" >}})

While reading this article, you may also find my [`.vimrc`](https://github.com/nickolashkraus/dotfiles/blob/master/.vimrc) helpful. Before we dive into Vim packages, its prudent to discuss how to manage them. I preferred to use Vundle.

**Note**: This article goes into great detail about each plugin. If you simply want to install these plugins and get to work, copy my [`.vimrc`](https://github.com/nickolashkraus/dotfiles/blob/master/.vimrc) and run:

```bash
vim +PluginInstall +qall
```

It should be noted, that you will still need to compile YouCompleteMe.

## Vundle
[VundleVim/Vundle.vim](https://github.com/VundleVim/Vundle.vim)

#### Overview
Vundle is a Vim plugin manager. It allows you to install, update, and configure Vim plugins all from within your `.vimrc`.

#### Installation

```bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

#### Configuration

Add the following to the top of your `.vimrc`:

`.vimrc`

```vim
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
```

#### Usage
Plugins are installed to `~/.vim/bundle/`.

To install plugins:

```
:PluginInstall
```

To install plugins from the command-line:

```bash
vim +PluginInstall +qall
```

## Productivity
### YouCompleteMe {#YouCompleteMe}
[Valloric/YouCompleteMe](https://github.com/Valloric/YouCompleteMe)

#### Overview
YouCompleteMe is a code completion engine for Vim. It provides a completion engine for many of the most common languages (C/C++, Python, C#, Go, etc.) in addition to a general identifier-based engine that works with every programming language. YouCompleteMe also leverages Vim’s omnicomplete system to provide semantic completions for many other languages for which a completion engine does not exist.

#### Installation
It should be noted that YouCompleteMe is a Vim Plugin with a compiled component. Simply installing the YouCompleteMe plugin is not enough to get it to work.

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'Valloric/YouCompleteMe'
```

Install Xcode Command Line Tools:

```bash
xcode-select --install
```

Install CMake:

```bash
brew install cmake
```

Compile YouCompleteMe with semantic support for C-family languages:

```bash
cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer
```

**Note**: If using pyenv, you need to run the command:

```bash
export PYTHON_CONFIGURE_OPTS="--enable-framework"
```

before installing a Python version.

#### Configuration
YouCompleteMe comes with sane defaults for its options, however here is my configuration:

`.vimrc`

```vim
" close preview window after completion
let g:ycm_autoclose_preview_window_after_completion=1

" map GoToDeclaration subcommand to <leader> + g
map <leader>g :YcmCompleter GoToDeclaration<CR>

" disable YouCompleteMe for file types: ['gitcommit']
let g:ycm_filetype_specific_completion_to_disable = {
      \ 'gitcommit': 1
      \}
```

#### Usage
YouCompleteMe requires no keyboard shortcuts to generate the list of completion candidates. Simply type and use `TAB` to cycle through the offered completions.

### ack.vim {#ack.vim}
[ack.vim](https://github.com/mileszs/ack.vim)

#### Overview
ack.vim allows you to search with `ack` (or any other search tool) from within Vim and shows the results in a split window.

#### Installation

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'mileszs/ack.vim'
```

#### Configuration

I prefer to use [Ag](https://github.com/ggreer/the_silver_searcher) with ack.vim:

`.vimrc`

```vim
" use Ag with ack.vim
let g:ackprg = 'ag --nogroup --nocolor --column'
```

#### Usage

Search recursively in `{directories}` (defaults to the current directory) for `{pattern}`:

```bash
:Ack [options] {pattern} [{directories}]
```

Files containing the search term will be listed in the quickfix window, along with the line number of the occurrence, once for each occurrence. Pressing `<Enter>` on a line in this window will open the file and place the cursor on the matching line.

### auto-pairs {#auto-pairs}
[jiangmiao/auto-pairs](https://github.com/jiangmiao/auto-pairs)

#### Overview
Auto-pairs allows you to insert or delete brackets, parentheses, or quotes in pair.

#### Installation

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'jiangmiao/auto-pairs'
```

#### Configuration

This plugin requires no further configuration.

#### Usage

This plugin has no further usage.

### nerdtree {#nerdtree}
[scrooloose/nerdtree](https://github.com/scrooloose/nerdtree)

#### Overview
The NERDTree is a file system explorer for the Vim editor.

#### Installation

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'scrooloose/nerdtree'
```

#### Configuration

`.vimrc`

```vim
" map toggle NERDTree to ^Ctrl + n
map <C-N> :NERDTreeToggle<CR>

" show hidden files by default
let NERDTreeShowHidden=1

" ignore specifc files
let NERDTreeIgnore=['\.pyc$', '\~$', '\.swp$']
```

#### Usage

Open NERDTree with a directory:

```bash
cd <directory>
vim .
```

Toggle NERDTree:

```
<Ctrl-n>
```

There is a plethora of helpful mappings for opening files and navigating directories. For a full list, see the [documentation](https://github.com/scrooloose/nerdtree/blob/master/doc/NERDTree.txt).

### syntastic {#syntastic}
[vim-syntastic/syntastic](https://github.com/vim-syntastic/syntastic)

#### Overview
If you use an IDE, you are accustom to having syntax errors displayed out of the box. This obfuscation removes the need for understanding how language checkers work. Syntastic disambiguates this process. It runs files through external syntax checkers and displays any resulting errors to the user. Syntastic does not presume what syntax checks you will want, therefore, in order to get meaningful results you need to install external checkers corresponding to the types of files you use.

#### Installation

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'vim-syntastic/syntastic'
```

#### Configuration

Syntastic has numerous options that can be configured and the defaults are not particularly well suitable for new users. It is recommended that you start by adding the following lines to your `.vimrc` file and return to them after reading the manual.

`.vimrc`

```vim
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
```

#### Usage

Add the following to your `.vimrc` to enable syntax checkers:

`.vimrc`

```vim
let g:syntastic_<filetype>_checkers = ['<checker_1>', '<checker_2>', ...]
```

### vim-anyfold {#vim-anyfold}
[pseewald/vim-anyfold](https://github.com/pseewald/vim-anyfold)

#### Overview

vim-anyfold is an enhancement of Vim’s native folding logic (`foldmethod=indent`).

#### Installation

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'pseewald/vim-anyfold'
```

#### Configuration

Add the following to your `.vimrc`:

`.vimrc`

```vim
autocmd Filetype * AnyFoldActivate
set foldlevel=99
```

#### Usage

Use Vim’s fold commands (`zo`, `zO`, `zc`, `za`) to fold/unfold folds.

Use key combinations `[[` and `]]` to navigate to the beginning and end of the current open fold.

Use `]k` and `[j` to navigate to the end of the previous block and to the beginning of the next block.

### vim-fugitive {#vim-fugitive}
[tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)

#### Overview

vim-fugitive is a Git wrapper which enables Git commands to be executed from within Vim.

#### Installation

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'tpope/vim-fugitive'
```

#### Configuration

This plugin requires no further configuration.

#### Usage

View a blob, tree, commit, or tag:

```vim
:Gedit (or :Gsplit, :Gvsplit, :Gtabedit)
```

Open the staged version of a file side by side with the working tree version:

```vim
:Gdiff
```

Open the output of `git status`:

```vim
:Gstatus
```

Press `-` to add/reset a file or `p` to add/reset with the `—patch` option.

Commit the current file and edit the commit message inside Vim:

```vim
:Gcommit %
```

Open an interactive vertical split with the output of `git blame`:

```vim
:Gblame
```

Execute `git mv` on a file and simultaneously rename the buffer:

```vim
:Gmove
```

Execute `git rm` on a file and simultaneously delete the buffer:

```vim
:Gdelete
```

Search the working tree with `git grep`:

```vim
:Ggrep
```

Load all previous revisions of a file into a quickfix list:

```vim
:Glog
```

Checkout a file to the buffer. This is synonymous with `git checkout -- filename`, however the operation is carried out on the buffer and not the file, so changes can be undone with `u`:

```vim
:Gread
```

Open the current file in the browser using a hosting provider (GitHub, GitLab, and Bitbucket):

```vim
:Gbrowse
```

**Note**: `:Gbrowse` requires an additional plugin.

Finally, run any Git command by simply using:

```vim
!Git <subcommand>
```

**Note**: Obviously, you need to be in a Git repository for vim-fugitive to work.

### vim-surround {#vim-surround}
[tpope/vim-surround](https://github.com/tpope/vim-surround)

#### Overview

vim-surround is all about *surroundings*: parentheses, brackets, quotes, XML tags, and more. The plugin provides mappings to easily delete, change, and add such surroundings in pairs.

#### Installation

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'tpope/vim-surround'
```

#### Configuration

This plugin requires no further configuration.

#### Usage

Change surroundings:

```
cs<current><new>
```

Remove surroundings:

```
ds<current>
```

Insert surroundings:

```
ysiw<new>
```

Wrap line with surroundings:

```
yss<new>
```

**Note**: For parentheses and brackets, an open character (`(`,`[`,`{`) will add spaces, a closed character (`)`,`]`,`}`) will not.

**Caveat**: Ensure that if you set a `timeoutlen` that it is not too short. The following does **not** allow a secondary key stoke to register before entering `INSERT` mode.

**Bad**
```
augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=0
    au InsertLeave * set timeoutlen=0
augroup END
```

**Good**
```
augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=100
    au InsertLeave * set timeoutlen=1000
augroup END
```

 This is problematic when a motion includes change (`c`).

### vitality {#vitality.vim}
[sjl/vitality.vim](https://github.com/sjl/vitality.vim)

#### Overview
Vitality is a plugin that makes Vim play nicely with iTerm2 and tmux. Specifically, Vitality restores the `FocusLost` and `FocusGained` autocommand functionality.

#### Installation

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'sjl/vitality.vim'
```

#### Configuration

This plugin requires no further configuration.

#### Usage

With Vitality, saving the current buffer (or all buffers) when focus is lost is possible within tmux:

```vim
" auto save all files when focus is lost or when switching buffers
autocmd FocusLost,BufLeave * :wa
```

## Code Formatting

### vim-autoformat {#vim-autoformat}
[Chiel92/vim-autoformat](https://github.com/Chiel92/vim-autoformat)

#### Overview

vim-autoformat makes use of external formatting programs to automatically format code. It is similar to syntastic in that it will try each formatter in a list of applicable formatters until one succeeds. If a formatting program for the specific language is not available, vim-autoformat falls back by default to indenting, re-tabbing, and removing trailing whitespace.

#### Installation

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'Chiel92/vim-autoformat'
```

Next, install an external program that can format code of the programming language you are using. For example, when working with Python, one could install the `autopep8` or `yapf` formatters.

#### Configuration

The `:Autoformat` command can be mapped to a specific key by adding the following to your `.vimrc`:

`.vimrc`

```vim
" set :Autoformat command to <F3>
noremap <F3> :Autoformat<CR>
```

#### Usage

Use the following command to format the entire buffer:

```vim
:Autoformat
```

To change the formatter with the highest priority, use the commands `:NextFormatter` and `:PreviousFormatter`. To print the currently selected formatter use `:CurrentFormatter`.

For debugging purposes, it may be beneficial to set vim-autoformat to verbose mode:

`.vimrc`

```vim
let g:autoformat_verbosemode=1
" or use the following:
let verbose=1
```

###  vim-python-pep8-indent {#vim-python-pep8-indent}
[Vimjas/vim-python-pep8-indent](https://github.com/Vimjas/vim-python-pep8-indent)

#### Overview
vim-python-pep8-indent  modifies Vim’s indentation behavior to comply with [PEP8](https://www.python.org/dev/peps/pep-0008/).

#### Installation

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'Vimjas/vim-python-pep8-indent'
```

#### Configuration

This plugin requires no further configuration.

#### Usage

This plugin has no further usage.

## Appearance

### lightline.vim {#lightline.vim}
[itchyny/lightline.vim](https://github.com/itchyny/lightline.vim)

#### Overview

lightline.vim is a light and configurable statusline plugin for Vim.

#### Installation

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'itchyny/lightline.vim'
```

#### Configuration

Add the following to your `.vimrc`:

`.vimrc`

```vim
" always display status line
set laststatus=2

" hide mode
set noshowmode
```

#### Usage

If you would like to display the Git branch, use the following configuration:

`.vimrc`

```vim
let g:lightline = {
      \ 'colorscheme': 'default',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }
```

### nerdtree-git-plugin {#nerdtree-git-plugin}
[Xuyuanp/nerdtree-git-plugin](https://github.com/Xuyuanp/nerdtree-git-plugin)

#### Overview

nerdtree-git-plugin works in concert with NERDTree to show Git status flags beside files.

#### Installation

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'Xuyuanp/nerdtree-git-plugin'
```

#### Configuration

Symbols can be changed using the `NERDTreeIndicatorMapCustom` variable, however, the defaults are quite acceptable.

#### Usage

This plugin has no further usage.

### vim-colors-solarized {#vim-colors-solarized}
[altercation/vim-colors-solarized](https://github.com/altercation/vim-colors-solarized)

#### Overview

[Solarized](https://ethanschoonover.com/solarized/) is a highly engineered color palette boasting both precise [CIELAB](https://en.wikipedia.org/wiki/CIELAB_color_space) lightness relationships and a refined set of hues based on fixed color wheel relationships. Solarized reduces brightness contrast but, unlike many low contrast colorschemes, retains contrasting hues (based on color wheel relations) for syntax highlighting readability. A lot of thought, planning, and testing has gone into making this colorscheme technically and aesthetically superior. I personally use the degraded 256 colorscheme, which offers grey monotones as oppose to blue to accommodate the limited 256 terminal palette.

#### Installation

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'altercation/vim-colors-solarized'
```

#### Configuration

To use the degraded 256 colorscheme, add the following to your `.vimrc`:

`.vimrc`

```vim
let g:solarized_termcolors=256
set background=dark
colorscheme solarized
```

#### Usage

If you are using a terminal emulator that supports 256 colors and do not want to use the custom Solarized terminal colors, you will need to use the degraded 256 colorscheme. To do so, simply add the following line *before* `colorscheme solarized`:

`.vimrc`

```vim
let g:solarized_termcolors=256
```

I use a custom terminal palette with iTerm2 which emulates the degraded 256 colorscheme. It can be found [here](https://github.com/nickolashkraus/dotfiles/blob/master/colorscheme.itermcolors).

### vim-gitgutter {#vim-gitgutter}
[airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter)

#### Overview

vim-gitgutter shows a `git diff` in the *gutter*, also known as the sign column, of lines that have been added, modified, or removed using signs (`+`, `~`, `-`, respectively). In addition, you can preview, stage, and undo individual *hunks* using simple motions.

#### Installation

Add the following to your `.vimrc`:

`.vimrc`

```vim
Plugin 'airblade/vim-gitgutter'
```

#### Configuration

After making a change to a file tracked by Git, diff markers should appear automatically after 4000 ms (Vim’s default *updatetime*). It is recommended that you reduce this time to 100 ms by adding the following to your `.vimrc`:

`.vimrc`

```vim
" set updatetime to 100 ms
set updatetime=100
```

#### Usage

Jump to next hunk:

```vim
]c
```

Jump to previous hunk:

```vim
[c
```

Preview a hunk:

```vim
<leader>hp
```

Stage a hunk:

```vim
<leader>hs
```

Undo a hunk:

```vim
<leader>hu
```

If you made it through this article, congratulations! Personally, I think a slow, piecemeal approach to extending Vim with plugins is the best way to go. There is a lot of nuance and a significant learning curve with each new plugin and it is best to read the documentation before blithely adding plugins to your `.vimrc`. If you would like more information on the Vim plugin ecosystem, [Vim Awesome](https://vimawesome.com/) maintains a comprehensive, ranked list of **all** Vim plugins.
