set nocompatible              " be iMproved, required
filetype off                  " required

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" set the runtime path to include Vundle and initialize
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes

"-------------------
"Plugin Insatll
"-------------------
" lsp
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

" auto complete
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'davidhalter/jedi-vim'

" others
Plug 'jiangmiao/auto-pairs'
Plug 'scrooloose/syntastic'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-commentary'

" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" theme
Plug 'morhetz/gruvbox'

call plug#end()
filetype plugin indent on    " required

"--------------
"VIM UI Config
"--------------
syntax on

let mapleader = "\<Space>"
inoremap jj <Esc>`^`       " map Esc to jj

"highlight current line
au WinLeave * set nocursorline nocursorcolumn
au WinEnter * set cursorline cursorcolumn
set cursorline cursorcolumn

"Edit Setting
set report=0
set number relativenumber
set showmatch
set showcmd                " show typed command in status bar
set title                  " show file in titlebar
set ruler                  "Always show current position
set laststatus=2           " use 2 lines for the status bar
set matchtime=2            " show matching bracket for 0.2 seconds
set matchpairs+=<:>        " specially for html
" set relativenumber

set autoindent
set smartindent
set shiftwidth=4
set tabstop=4
set expandtab
set backspace=indent,eol,start

" theme
colorscheme gruvbox
set background=dark

"-----------------
"Plugin Config
"-----------------

"Nerd Tree
nmap <F4> :NERDTreeToggle<cr>

let NERDChristmasTree=0
let NERDTreeWinSize=30
let NERDTreeChDirMode=2
let NERDTreeIgnore=['\~$', '\.pyc$', '\.swp$']
" let NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$',  '\~$']
let NERDTreeShowBookmarks=1
let NERDTreeWinPos = "right"
let g:NERDTreeNodeDelimiter = "\u00a0"

"Syntastics
let g:syntastic_error_symbol='>>'
let g:syntastic_warning_symbol='>'
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=1
let g:syntastic_enable_highlighting=0
let g:syntastic_python_checkers=['flake8']
"highlight SyntasticErrorSign guifg=white guibg=black
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_loc_list_height = 5

function! ToggleErrors()
    let old_last_winnr = winnr('$')
    lclose
    if old_last_winnr == winnr('$')
        " Nothing was closed, open syntastic error location panel
        Errors
    endif
endfunction

nnoremap <leader>s  :call ToggleErrors()<cr>
nnoremap <leader>sn :lnext<cr>
nnoremap <leader>sp :lprevious<cr>

" lsp setting
if executable('pyls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ 'workspace_config': {'pyls': {'plugins': {'pydocstyle': {'enabled': v:true}}}}
        \ })
endif

let g:lsp_diagnostics_enabled = 0         " disable diagnostics support
let g:lsp_document_highlight_enabled = 0  " disable highlight references

" jedi
let g:jedi#use_tabs_not_buffers = 1
let g:jedi#goto_definitions_command = "<C-f>"
let g:jedi#popup_select_first = 1
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

"-----------------
"Useful Function
"-----------------

"Easier navigation between split windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Map Ctrl + p to open fuzzy find (FZF)
nnoremap <c-p> :Files<cr>

"Python File Head
function HeaderPython()
    call setline(1, "#!/usr/bin/env python3")
    normal G
    normal o
    normal o
endfunction
autocmd bufnewfile *.py call HeaderPython()

"Auto Compile and Run
map <F5> :call CompileRunGcc()<CR>
function! CompileRunGcc()
    exec "w"
    if &filetype == 'c'
        exec '!g++ % -o %<'
        exec '!./%<'
    elseif &filetype == 'cpp'
        exec '!g++ % -o %<'
        exec '!./%<'
    elseif &filetype == 'python'
        exec '!python3 %'
    elseif &filetype == 'sh'
        :!bash %
    endif
endfunction
