" Ward off unexpected things that your distro might have made, as
" well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Set Dein base path (required)
let s:dein_base = '/root/.vim/dein'

" Set Dein source path (required)
let s:dein_src = '/root/.cache/dein/repos/github.com/Shougo/dein.vim'

" Set Dein runtime path (required)
execute 'set runtimepath+=' . s:dein_src

if dein#load_state(s:dein_base)
 call dein#begin(s:dein_base)
 let s:toml = '/root/.vim/dein/dein.toml'
 call dein#load_toml(s:toml, {'lazy':0})
 call dein#end()
 call dein#save_state()
endif

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting
syntax enable

" Uncomment if you want to install not-installed plugins on startup.
if dein#check_install()
 call dein#install()
endif
