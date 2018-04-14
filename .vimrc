set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8

set nocompatible              

syntax on
syntax enable 

"Clip board enable
set clipboard=unnamed

" Enable OS mouse clicking and scrolling
if has("mouse")
    set mouse=a
endif

" Set sell type
set shell=bash\ -i

" Bash-style tab completion
set wildmode=longest,list
set wildmenu

" Fix trailing selection on visual copy/cut
set selection=exclusive

"  Emacs-style start of line / end of line navigation
nnoremap <silent> <C-a> ^
nnoremap <silent> <C-e> $
vnoremap <silent> <C-a> ^
vnoremap <silent> <C-e> $
inoremap <silent> <C-a> <esc>^i
inoremap <silent> <C-e> <esc>$i

"  Emacs-style line cutting
nnoremap <silent> <C-k> d$
vnoremap <silent> <C-k> d$
inoremap <silent> <C-k> <esc>d$i

"  Fix Alt key in MacVIM GUI
if has("gui_macvim")
   set macmeta
endif

"  Emacs-style start of file / end of file navigation
nnoremap <silent> <M-<> gg
nnoremap <silent> <M->> G$
vnoremap <silent> <M-<> gg
vnoremap <silent> <M->> G$
inoremap <silent> <M-<> <esc>ggi
inoremap <silent> <M->> <esc>G$i

"  Disable comment continuation on paste
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Show line numbers
set number

" Show statusline
set laststatus=2

" Case-insensitive search
set ignorecase

" Highlight search results
set hlsearch

" Default to soft tabs, 2 spaces
set expandtab
set sw=2
set sts=2

"  Except Markdown
autocmd FileType mkd set sw=4
autocmd FileType mkd set sts=4
autocmd vimenter * NERDTree

" Default to Unix LF line endings
set ffs=unix

" Folding
set foldmethod=syntax
set foldcolumn=1
set foldlevelstart=20

" Lets
let g:vim_markdown_folding_disabled=1 " Markdown
let javaScript_fold=1                 " JavaScript
let perl_fold=1                       " Perl
let php_folding=1                     " PHP
let r_syntax_folding=1                " R
let ruby_fold=1                       " Ruby
let sh_fold_enabled=1                 " sh
let vimsyn_folding='af'               " Vim script
let xml_syntax_folding=1              " XML
let g:nerdtree_tabs_open_on_console_startup=1
let g:nerdtree_tabs_focus_on_files=1
let g:nerdtree_tabs_smart_startup_focus=2
let g:NERDTreeIgnore=['node_modules', 'bower_components', 'tmp', 'vendor']

" Autocmd
autocmd BufRead,BufNewFile *.Dockerfile set filetype=dockerfile
autocmd BufRead,BufNewFile Vagrantfile set filetype=ruby
autocmd BufRead,BufNewFile *.Vagrantfile set filetype=ruby
autocmd BufRead,BufNewFile *.cql set filetype=cql

"  Wrap window-move-cursor
function! s:GotoNextWindow( direction, count )
	let l:prevWinNr = winnr()
		execute a:count . 'wincmd' a:direction
		return winnr() != l:prevWinNr
	endfunction

        function! s:JumpWithWrap( direction, opposite )
	if ! s:GotoNextWindow(a:direction, v:count1)
		call s:GotoNextWindow(a:opposite, 999)
	endif
endfunction

" Maps
nnoremap <silent> <C-w>h :<C-u>call <SID>JumpWithWrap('h', 'l')<CR>
nnoremap <silent> <C-w>j :<C-u>call <SID>JumpWithWrap('j', 'k')<CR>
nnoremap <silent> <C-w>k :<C-u>call <SID>JumpWithWrap('k', 'j')<CR>
nnoremap <silent> <C-w>l :<C-u>call <SID>JumpWithWrap('l', 'h')<CR>
nnoremap <silent> <C-w><Left> :<C-u>call <SID>JumpWithWrap('h', 'l')<CR>
nnoremap <silent> <C-w><Down> :<C-u>call <SID>JumpWithWrap('j', 'k')<CR>
nnoremap <silent> <C-w><Up> :<C-u>call <SID>JumpWithWrap('k', 'j')<CR>
nnoremap <silent> <C-w><Right> :<C-u>call <SID>JumpWithWrap('l', 'h')<CR>
inoremap <silent> <C-w>h <esc>:<C-u>call <SID>JumpWithWrap('h', 'l')<CR>
inoremap <silent> <C-w>j <esc>:<C-u>call <SID>JumpWithWrap('j', 'k')<CR>
inoremap <silent> <C-w>k <esc>:<C-u>call <SID>JumpWithWrap('k', 'j')<CR>
inoremap <silent> <C-w>l <esc>:<C-u>call <SID>JumpWithWrap('l', 'h')<CR>
inoremap <silent> <C-w><Left> <esc>:<C-u>call <SID>JumpWithWrap('h', 'l')<CR>
inoremap <silent> <C-w><Down> <esc>:<C-u>call <SID>JumpWithWrap('j', 'k')<CR>
inoremap <silent> <C-w><Up> <esc>:<C-u>call <SID>JumpWithWrap('k', 'j')<CR>
inoremap <silent> <C-w><Right> <esc>:<C-u>call <SID>JumpWithWrap('l', 'h')<CR>

" Enables CtrlP
set runtimepath^=~/.vim/bundle/ctrlp.vim

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
  Plugin 'VundleVim/Vundle.vim'
  Plugin 'dracula/vim'
  Plugin 'scrooloose/nerdtree'
  Plugin 'tpope/vim-fugitive'
  Plugin 'git://git.wincent.com/command-t.git'
  Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}

call vundle#end()            " required
filetype plugin indent on    " required

" Color Theme
color dracula
